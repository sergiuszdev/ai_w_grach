extends GroundEnemy

@onready var sprite = $AnimatedSprite2D
@onready var vision = $Vision
@onready var ledge_check = $LedgeCheck
@onready var hitbox := $BodyShape
@onready var attack_shape := $Attack/Area2D/attack_shape



const ARROW_SCENE = preload("res://enemies/arrow.tscn")
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

enum State { ATTACK1, ATTACK2, ATTACK3, DEAD, EVASION, HURT, IDLE, SHOT1, SHOT2, WALK }

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
var shot_cooldown_time := 3.0
var evasion_timer := 0.0
var evasion_time := 1.0
var evade = false
var dmg := 5
var hp := 500

var target_player: Node2D = null

func update_animation():
	match state:
		State.ATTACK1: sprite.play("Attack1")
		State.ATTACK2: sprite.play("Attack2")
		State.ATTACK3: sprite.play("Attack3")
		State.DEAD: sprite.play("Dead")
		State.EVASION: sprite.play("Evasion")
		State.HURT: sprite.play("Hurt")
		State.IDLE: sprite.play("Idle")
		State.SHOT1: sprite.play("Shot1")
		State.SHOT2: sprite.play("Shot2")
		State.WALK: sprite.play("Walk")
		
func _ready():
	super._ready()
	sprite.frame_changed.connect(_on_frame_changed)

func _on_frame_changed():
	if state == State.ATTACK1:
		if sprite.frame == 4:  # numer klatki, na której ma się włączyć hitbox
			attack_shape.disabled = false
	else:
		attack_shape.disabled = true

func ai_update(delta):
	
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
		state = State.IDLE
		return

	if not is_dead():
		if state == State.ATTACK1:
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
			
		elif state == State.EVASION:
			if evasion_timer == 0.0:
				var def = randi()%101 + 1
				if def > 50:
					evade = true
				else:
					evade = false
			evasion_timer += delta
			if evasion_timer >= evasion_time: 
				evasion_timer = 0.0
				state = State.IDLE
			return
		
		if target_player != null:
			var dir_to_player = sign(target_player.global_position.x - global_position.x)
			
			if dir_to_player != 0:
				# Odwracanie grafiki
				sprite.flip_h = dir_to_player < 0
				vision.scale.x = -1 if sprite.flip_h else 1
				# Przesunięcie czujnika krawędzi przed szkieleta
				ledge_check.position.x = 15.0 * dir_to_player
				attack_shape.position.x = 24.0 * dir_to_player
			
			var distance_x = abs(target_player.global_position.x - global_position.x)
			
			if distance_x <= 35.0:
				velocity.x = 0
				if target_player.is_attacking:
					state = State.EVASION
				else:
					state = State.ATTACK1
					return
			else:
				velocity.x = 0
				if shot_cooldown_timer <= 0.0:
					state = State.SHOT1
					shot_timer += delta
					
					if shot_timer >= shot_time:
						shot_timer = 0.0
						shot_cooldown_timer = shot_cooldown_time
						shoot_arrow()
				else:
					shot_cooldown_timer -= delta
					state = State.IDLE
				return

			# przepasc/sciana
			if not ledge_check.is_colliding() or is_on_wall():
				velocity.x = 0
				state = State.IDLE
				return

			# Droga wolna – biegnij za graczem
			state = State.WALK
			velocity.x = dir_to_player * speed
			return

		# --- PATROLOWANIE (Wykona się tylko, gdy target_player == null)
		elif state == State.IDLE:
			velocity.x = 0
			idle_timer += delta
			if idle_timer >= idle_time:
				idle_timer = 0.0
				state = State.WALK
				if randf() < 0.5:
					patrol_dir *= -1

		elif state == State.WALK:
			walk_timer += delta
			
			# Ustawiamy wzrok i czujnik w stronę marszu
			sprite.flip_h = patrol_dir < 0
			vision.scale.x = -1 if sprite.flip_h else 1
			ledge_check.position.x = 15.0 * patrol_dir
			attack_shape.position.x = 24.0 * patrol_dir
			
			# Zawracanie przed przepaścią ALBO przed ścianą
			if not ledge_check.is_colliding() or is_on_wall():
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
				
	else:
		delete_hitboxes()

		

func _on_vision_player_detected(body: Node2D):
	target_player = body

func _on_vision_player_lost():
	target_player = null
	state = State.IDLE
	
func is_dead():
	return hp<1
	
func hit(damage, attacker: Node2D = null):
	if evade == true:
		damage /= 2
	hp -= damage
	print(hp)

	if attacker != null and target_player == null:
		var dir_to_attacker = sign(attacker.global_position.x - global_position.x)
		if dir_to_attacker != 0:
			patrol_dir = dir_to_attacker
			sprite.flip_h = patrol_dir < 0
			vision.scale.x = -1 if sprite.flip_h else 1
			ledge_check.position.x = 15.0 * patrol_dir
			attack_shape.position.x = 24.0 * patrol_dir
			print("flip_h set to: ", sprite.flip_h)

	if is_dead():
		state = State.DEAD
		
func shoot_arrow():
	var arrow = ARROW_SCENE.instantiate()
	print("arrow shot")
	arrow.global_position = global_position
	arrow.global_position.y += 13.0
	arrow.direction = -1 if sprite.flip_h else 1
	get_tree().get_root().add_child(arrow)

	
func delete_hitboxes():
	hitbox.set_deferred("disabled", true)
	#attack_shape.set_deferred("disabled", true)
	vision.set_deferred("disabled", true)
	ledge_check.set_deferred("disabled", true)
	set_physics_process(false)


#atak sztyletem
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("hit"):
		print("dmg")
		body.hit(dmg)
