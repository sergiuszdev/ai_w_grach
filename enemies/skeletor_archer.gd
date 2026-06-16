extends GroundEnemy

@onready var sprite = $AnimatedSprite2D
@onready var vision = $Vision
@onready var ledge_check = $LedgeCheck
@onready var ledge_check2 = $LedgeCheck2
@onready var hitbox := $BodyShape
@onready var attack_shape := $Attack/Area2D/attack_shape



const ARROW_SCENE = preload("res://enemies/arrow.tscn")
const SPEED = 100000.0
const JUMP_VELOCITY = -400.0
const ARROW_SPEED := 1000.0

enum State { ATTACK1, ATTACK2, ATTACK3, DEAD, EVASION, HURT, IDLE, SHOT1, SHOT2, WALK, ESCAPE, FOLLOW }

var state: State = State.IDLE
var patrol_dir := 1
var idle_timer := 0.0
var idle_time := 1.0
var walk_timer := 0.0
var walk_time := 5.0
var attack_timer := 0.0
var attack_time := 1.0
var shot_timer := 0.0
var shot_time := 0.66
var shot_cooldown_timer := 0.0
var shot_cooldown_time := 2.0
var evasion_timer := 0.0
var evasion_time := 1.0
var run_timer := 0.0
var run_time := 2.0
var evade = false
var dmg := 5
var hp := 500
var spawn_position := Vector2.ZERO

var target_player: Node2D = null

func update_animation():
	match state:
		State.ATTACK1: sprite.play("Attack1")
		State.ATTACK2: sprite.play("Attack2")
		State.ATTACK3: sprite.play("Attack3")
		State.DEAD: sprite.play("Dead")
		State.EVASION: sprite.play("Evasion")
		State.HURT: sprite.play("Hurt")
		#State.IDLE: sprite.play("Idle")
		#State.SHOT1: sprite.play("Shot1")
		State.SHOT2: sprite.play("Shot2")
		State.WALK: sprite.play("Walk")
		State.ESCAPE: sprite.play("Walk")
		State.FOLLOW: sprite.play("Walk")
		
func _ready():
	super._ready()
	sprite.frame_changed.connect(_on_frame_changed)
	spawn_position = global_position

func _on_frame_changed():
	if state == State.ATTACK1:
		if sprite.frame == 4:  # numer klatki, na której ma się włączyć hitbox
			attack_shape.disabled = false
	else:
		attack_shape.disabled = true

func ai_update(delta):
	if not is_dead():
		if state == State.IDLE:
			#print("idle")
			velocity.x = 0
			idle_timer += delta
			shot_cooldown_timer -= delta
			if player_spotted():
				if shot_cooldown_timer <= 0:
					idle_timer = 0
					state = get_attack_state()
					return
			else:
				sprite.play("Idle")
			if idle_timer >= idle_time:
				idle_timer = 0
				state = State.WALK
				
		elif state == State.WALK:
			if player_spotted():
				idle_timer = 0
				state = get_attack_state()
				return
			walk_timer += delta
			
			# Ustawiamy wzrok i czujnik w stronę marszu
			flip(patrol_dir)
			
			var distance_from_spawn = global_position.x - spawn_position.x
			var reached_limit = (patrol_dir > 0 and distance_from_spawn >= 500) or(patrol_dir < 0 and distance_from_spawn <= -500.0)
			
			# Zawracanie przed przepaścią ALBO przed ścianą
			if not ledge_check.is_colliding() or not ledge_check2.is_colliding() or is_on_wall() or reached_limit:
				patrol_dir *= -1
				walk_timer = 0.0
				state = State.IDLE
				velocity.x = 0
				return
				
			# Spokojny marsz
			velocity.x = patrol_dir * speed * 0.5
			
			if walk_timer >= walk_time:
				walk_timer = 0.0
				state = State.IDLE
		elif state == State.ESCAPE:
			var dir_to_player = sign(target_player.global_position.x - global_position.x)
			
			#odwracanie grafiki
			if dir_to_player != 0:
				flip(-dir_to_player)
			velocity.x = -dir_to_player * speed
			
			state = get_attack_state(dir_to_player)
				
		elif state == State.ATTACK1:
			attack_timer += delta
			
			if target_player != null:
				var distance_x = abs(target_player.global_position.x - global_position.x)
				if distance_x > 45.0: 
					attack_timer = 0.0
					state = State.WALK 
					return 
			
			if attack_timer >= attack_time:
				attack_timer = 0.0
				state = State.IDLE
			return
				
		elif state == State.SHOT1:
			velocity.x = 0
			if shot_cooldown_timer <= 0.0:
				sprite.play("Shot1")
				shot_timer += delta
				
				if shot_timer >= shot_time:
					shot_timer = 0.0
					shot_cooldown_timer = shot_cooldown_time
					shoot_arrow()
			else:
				shot_cooldown_timer -= delta
				sprite.play("Idle")
				state = get_attack_state()
			return
					
		elif state == State.FOLLOW:
			if target_player != null:
				var dir_to_player = sign(target_player.global_position.x - global_position.x)
				flip(dir_to_player)
				velocity.x = dir_to_player*speed
				state = get_attack_state()
			
			
	else:
		delete_hitboxes()

		

func _on_vision_player_detected(body: Node2D):
	target_player = body
	print("Player detected")

func _on_vision_player_lost():
	target_player = null
	state = State.IDLE
	
func player_spotted():
	return target_player != null
	
func is_dead():
	return hp<1
	
func hit(damage):
	if evade == true:
		damage /= 2
	hp -= damage
	print(hp)
	
	if is_dead():
		state = State.DEAD

	if target_player == null:
		self.scale.x *= -1

	
		
func shoot_arrow():
	var arrow = ARROW_SCENE.instantiate()
	var spawn_pos = global_position + Vector2(0,13.0)
	arrow.global_position = spawn_pos
	
	var to_player = target_player.global_position - spawn_pos
	
	var vx = ARROW_SPEED
	var dx = abs(to_player.x)
	var dy = to_player.y
	var t = dx/vx
	var vy = (dy - 0.5*gravity*t*t)/t
	
	var dir_x = -1.0 if sprite.flip_h else 1.0
	
	arrow.velocity = Vector2(vx * dir_x, vy)
	
	if dir_x <0:
		arrow.scale.x = -1
		
	get_tree().get_root().add_child(arrow)

func get_attack_state(dir = 0):
	if target_player:
		if dir!=0:
			flip(dir)
		var distance_x = abs(target_player.global_position.x - global_position.x)
		if distance_x <= 35:
			return State.ATTACK1
		elif distance_x >= 400:
			return State.FOLLOW
			
		elif distance_x >= 200:
			return State.SHOT1
		else:
			if not ledge_check.is_colliding() or not ledge_check2.is_colliding() or is_on_wall():
				return State.SHOT1
			else:
				return State.ESCAPE
			
			
	
func delete_hitboxes():
	hitbox.set_deferred("disabled", true)
	#attack_shape.set_deferred("disabled", true)
	vision.set_deferred("disabled", true)
	ledge_check.set_deferred("disabled", true)
	ledge_check2.set_deferred("disabled", true)
	set_physics_process(false)
	
func flip(dir):
	sprite.flip_h = dir < 0
	vision.scale.x = -1 if sprite.flip_h else 1
	attack_shape.position.x = 24.0 * dir


#atak sztyletem
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("hit"):
		print("dmg")
		body.hit(dmg)
