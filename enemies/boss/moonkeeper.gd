extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

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

var target_player: Node2D = null


func _ready():
	animation_tree.active = true


func _physics_process(delta):

	if not is_on_floor():
		velocity.y += (gravity / 4) * delta

	#ai_update(delta)

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

	if state in [
		States.ATTACK_1,
		States.ATTACK_2,
		States.HIT,
		States.DEATH,
		States.DASH
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


func attack_1():
	state = States.ATTACK_1
	velocity.x = 0


func attack_2():
	state = States.ATTACK_2
	velocity.x = 0


func hit():
	state = States.HIT


func die():
	state = States.DEATH
	velocity = Vector2.ZERO
