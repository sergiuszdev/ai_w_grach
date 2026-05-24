extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var MAX_HEALTH = 1000
@export var current_hp = MAX_HEALTH

@onready var sprite := $Animations/AnimatedSprite2D
@onready var animation_tree := $Animations/AnimationTree
@onready var playback = animation_tree["parameters/playback"]

enum States {
	IDLE,
	ATTACK_1,
	ATTACK_2,
	DASH,
	DEATH,
	HIT,
	JUMP,
	JUMP_LOOP,
	LAND,
	RUN,
	WALK
}

var state: States = States.IDLE

@export var speed := 100.0
@export var dash_speed := 450.0
@export var jump_force := -500.0

var target_player: Node2D = null

var paused := false
var is_dashing := false


func _ready():
	animation_tree.active = true
	target_player = get_tree().get_first_node_in_group("player")


func _physics_process(delta):

	if paused:
		velocity = Vector2.ZERO
		return

	if not is_on_floor():
		velocity.y += (gravity / 4) * delta

	ai_update(delta)
	update_animation()
	move_and_slide()


func update_animation():

	if not is_on_floor():

		if velocity.y < 0:
			playback.travel("jump")
		else:
			playback.travel("jump_loop")

		return

	match state:

		States.IDLE:
			playback.travel("idle")

		States.WALK:
			playback.travel("walk")

		States.RUN:
			playback.travel("run")

		States.ATTACK_1:
			playback.travel("attack_1")

		States.ATTACK_2:
			playback.travel("attack_2")

		States.DASH:
			playback.travel("dash")

		States.HIT:
			playback.travel("hit")

		States.LAND:
			playback.travel("land")

		States.DEATH:
			playback.travel("death")


func ai_update(_delta):

	if is_dashing:
		return

	# ADD States.JUMP here so ai doesn't override scripted jumps
	if state in [
		States.ATTACK_1,
		States.ATTACK_2,
		States.HIT,
		States.DEATH,
		States.DASH,
		States.JUMP,      # ← add this
		States.JUMP_LOOP  # ← add this
	]:
		velocity.x = 0
		return

	if target_player != null:
		var dir = sign(target_player.global_position.x - global_position.x)
		velocity.x = dir * speed
		if abs(velocity.x) > 10:
			state = States.RUN
		else:
			state = States.IDLE
		sprite.flip_h = velocity.x < 0
	else:
		velocity.x = move_toward(velocity.x, 0, 500 * get_physics_process_delta_time())
		if abs(velocity.x) < 5:
			state = States.IDLE


func jump():

	if not is_on_floor():
		return

	state = States.JUMP
	velocity.y = jump_force


func dash(direction: float):

	is_dashing = true
	state = States.DASH
	velocity.x = direction * dash_speed

	await get_tree().create_timer(0.25).timeout

	is_dashing = false


func jump_to_pos_then_attack(moon_position: Vector2):
	print("jump and attack")

	var dir = sign(moon_position.x - global_position.x)

	state = States.JUMP
	velocity.x = dir * speed * 2.0  # give it enough horizontal to reach moon
	velocity.y = jump_force
	
	# wait until boss lands
	await get_tree().create_timer(0.8).timeout

	# snap state so ai_update stays blocked
	state = States.ATTACK_1
	velocity.x = 0

	await get_tree().create_timer(0.3).timeout

	var player_dir = sign(target_player.global_position.x - global_position.x)
	await dash(player_dir)

	# return control to ai after scripted sequence
	state = States.IDLE


func attack_1():
	state = States.ATTACK_1
	velocity.x = 0


func attack_2():
	state = States.ATTACK_2
	velocity.x = 0


func hit(amount):
	current_hp -= amount
	print("moonkeeper hp: ", current_hp)
	state = States.HIT


func die():
	state = States.DEATH
	velocity = Vector2.ZERO


func pause():
	paused = true
	velocity = Vector2.ZERO
	set_physics_process(false)


func resume():
	paused = false
	set_physics_process(true)
	
func get_max_health():
	return MAX_HEALTH
	
func get_health():
	return current_hp
	
