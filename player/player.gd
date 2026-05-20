extends CharacterBody2D

@export var SPEED := 200.0
@export var ACCELERATION := 800.0
@export var FRICTION := 900.0
@export var JUMP_VELOCITY := -400.0

@onready var animation_tree = $Animations/AnimationTree
@onready var playback = animation_tree["parameters/playback"]

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var jumps_remaining := 2
const MAX_JUMPS := 2

var direction := 0.0

func _ready():
	animation_tree.active = true

func update_animation():

	if not is_on_floor():
		if velocity.y < 0:
			playback.travel("jump")
		#else:
			#playback.travel("fall")
		return

	if velocity != Vector2.ZERO and is_on_floor():
		playback.travel("run")
	else:
		playback.travel("idle")
	
func get_input():
	direction = Input.get_axis("left", "right")

func _physics_process(delta):

	get_input()


	if not is_on_floor():
		velocity.y += gravity * delta


	if is_on_floor():
		jumps_remaining = MAX_JUMPS

	if Input.is_action_just_pressed("jump") and jumps_remaining > 0:
		velocity.y = JUMP_VELOCITY
		jumps_remaining -= 1


	if direction != 0:
		velocity.x = move_toward(
			velocity.x,
			direction * SPEED,
			ACCELERATION * delta
		)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)


	if direction != 0:
		$Animations/AnimatedSprite2D.flip_h = direction < 0

	update_animation()

	move_and_slide()
