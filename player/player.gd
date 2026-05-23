extends CharacterBody2D

@export var SPEED := 200.0
@export var ACCELERATION := 800.0
@export var FRICTION := 900.0
@export var JUMP_VELOCITY := -400.0

@onready var animation_tree := $FlipGroup/Animations/AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# attack hitboxes
@onready var vertical_attack_area = $FlipGroup/Attacks/VerticalAttackArea
@onready var upper_attack_area = $FlipGroup/Attacks/UpperAttack
@onready var lower_attack_area = $FlipGroup/Attacks/LowerAttack

var is_attacking := false
var jumps_remaining := 2
@export var MAX_JUMPS := 1
var direction := 0.0

func _ready():
	animation_tree.active = true
	disable_hitboxes()

func update_animation():
	if is_attacking:
		return

	if not is_on_floor():
		if velocity.y < 0:
			playback.travel("jump")
		return

	if abs(velocity.x) > 5:
		playback.travel("run")
		#print("current playback state: ", playback.get_current_node())
		
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
		normal_jump()
	
	handle_attack_hitboxes()
	
	
	if Input.is_action_just_pressed("attack_1"):
		attack()
	
	
	if direction != 0:
		velocity.x = move_toward(
			velocity.x,
			direction * SPEED,
			ACCELERATION * delta
		)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)


	if direction != 0:
		$FlipGroup.scale.x = -1 if direction < 0 else 1

	update_animation()

	move_and_slide()

func attack():
	if Input.is_action_pressed("up"):
		do_upper_attack()

	elif Input.is_action_pressed("down") and not is_on_floor():
		do_lower_attack()
		print("loopuje sie")
	else:
		print("normal attack")
		do_normal_attack()

func do_upper_attack():
	pass

func do_lower_attack():
	
	lower_attack_area.monitoring = true
	lower_attack_area.visible = true

	#await get_tree().create_timer(0.15).timeout
	#Input.action_release("down")
	lower_attack_area.monitoring = false
	lower_attack_area.visible = false
	
func do_normal_attack():
	is_attacking = true
	playback.travel("attack")
	

func pogo_jump():
	jump()
	jumps_remaining = MAX_JUMPS
func normal_jump():
	jump()
	jumps_remaining -= 1

func jump():
	velocity.y = JUMP_VELOCITY
	
func disable_hitboxes():
	upper_attack_area.monitoring = false
	upper_attack_area.visible = false
	lower_attack_area.monitoring = false
	lower_attack_area.visible = false

func handle_attack_hitboxes():
	if Input.is_action_pressed("up"):
		vertical_attack_area.monitoring = false
		vertical_attack_area.visible = false
		
		upper_attack_area.monitoring = true
		upper_attack_area.visible = true
		
	elif Input.is_action_pressed("down"):
		vertical_attack_area.monitoring = false
		vertical_attack_area.visible = false
		
		lower_attack_area.monitoring = true
		lower_attack_area.visible = true
		
	if Input.is_action_just_released("up"):
		vertical_attack_area.monitoring = true
		vertical_attack_area.visible = true
		upper_attack_area.monitoring = false
		upper_attack_area.visible = false
	if Input.is_action_just_released("down"):
		vertical_attack_area.monitoring = true
		vertical_attack_area.visible = true
		lower_attack_area.monitoring = false
		lower_attack_area.visible = false

func on_attack_start():
	print("attack started")

func on_attack_ended():
	print("attack ended")
	is_attacking = false
	#playback.travel("idle")
	print(is_attacking)

func _on_lower_attack_body_entered(body):
	print("lower attack hit: ", body)
#	somehow it works now 
	if Input.is_action_pressed("attack_1") and Input.is_action_pressed("down"):
		if velocity.y >= 0:
			pogo_jump()
			disable_hitboxes()
			print("pogo jump!")
		
#		todo implement dmg 
		#if body.has_method("hit"):
			#body.hit(1)
