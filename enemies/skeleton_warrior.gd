extends GroundEnemy

@onready var sprite = $AnimatedSprite2D
@onready var animation_tree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]
@onready var vision := $Vision
@onready var ledge_check := $LedgeCheck 
@onready var attack_shape := $Attack/Area2D/AttackShape
@onready var hitbox := $BodyShape

const key = preload("res://levels/globals/key.tscn")

enum State { IDLE, WALK, RUN, ATTACK, HURT, PROTECT, DEAD }

var state: State = State.IDLE
var patrol_dir := 1
var idle_timer := 0.0
var idle_time := 2.0
var walk_timer := 0.0
var walk_time := 2.5
var attack_timer := 0.0
var attack_time := 1.0
var protect_timer := 0.0
var protect_time := 0.2
var dmg := 10
var hp := 40

var target_player: Node2D = null

func update_animation():
	match state:
		State.DEAD:     playback.travel("dead")
		State.HURT:     playback.travel("hurt")
		State.ATTACK:   playback.travel("attack")
		State.PROTECT:  playback.travel("protect")
		State.WALK:     playback.travel("walk")
		State.IDLE:     playback.travel("idle")
		State.RUN:      playback.travel("run")

func ai_update(delta):

	if not is_dead():
		if state == State.ATTACK:
			attack_timer += delta
			
			if target_player != null:
				var distance_x = abs(target_player.global_position.x - global_position.x)
				if distance_x > 45.0: 
					attack_timer = 0.0
					state = State.RUN 
					return 
			
			if attack_timer >= attack_time:
				attack_timer = 0.0
				state = State.IDLE
			return
			
		# --- STAN OBRONY
		elif state == State.PROTECT:
			protect_timer += delta
			if protect_timer >= protect_time: 
				protect_timer = 0.0
				state = State.IDLE
			return
		# --- LOGIKA SLEDZENIA GRACZA
		if target_player != null:
			var dir_to_player = sign(target_player.global_position.x - global_position.x)
			
			if dir_to_player != 0:
				# Odwracanie grafiki
				sprite.flip_h = dir_to_player < 0
				vision.scale.x = -1 if sprite.flip_h else 1
				# Przesunięcie czujnika krawędzi przed szkieleta
				ledge_check.position.x = 15.0 * dir_to_player
				attack_shape.position.x = 24.0 * dir_to_player
			
			# POPRAWIONO: Mierzenie dystansu tylko na osi X (bardziej stabilne dla sidescrollera)
			var distance_x = abs(target_player.global_position.x - global_position.x)
			
			# Zwiększyłem delikatnie zasięg do 35.0, żeby łatwiej trafiał z lewej strony
			if distance_x <= 35.0:
				velocity.x = 0
				if target_player.is_attacking:
					state = State.PROTECT
				else:
					state = State.ATTACK
				return

			# przepasc/sciana
			if not ledge_check.is_colliding() or is_on_wall():
				velocity.x = 0
				state = State.IDLE
				return

			# Droga wolna – biegnij za graczem
			state = State.RUN
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
		

# --- SYGNAŁY WZROKU ---
func _on_vision_player_detected(body: Node2D):
	target_player = body

func _on_vision_player_lost():
	target_player = null
	state = State.IDLE


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		state=State.IDLE

#dmg dla gracza
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("hit"):
		print("dmg")
		body.hit(dmg)
		
#dostawanie obrazen
func hit(dmg):
	hp -= dmg
	print(hp)
	if is_dead():
		state = State.DEAD
		var new_key = key.instantiate()
		new_key.global_position = self.global_position + Vector2(0, 40)
		get_parent().add_child(new_key) 
	print("skeleton dmg")
	
func is_dead():
	return hp<1
	
func delete_hitboxes():
	hitbox.set_deferred("disabled", true)
	attack_shape.set_deferred("disabled", true)
	vision.set_deferred("disabled", true)
	ledge_check.set_deferred("disabled", true)
	set_physics_process(false)
