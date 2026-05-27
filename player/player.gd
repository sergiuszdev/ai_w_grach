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
var is_healing := false
var is_attacking := false
var is_sliding := false
var jumps_remaining := 2
@export var MAX_JUMPS := 1
var direction := 0.0
@onready var wall_jumps = 1
@onready var is_pogo := false

@export var attack_cooldown_time := Globals.player_attack_cooldown
@onready var is_attack_ready := true

@onready var attack_cooldown_timer = $FlipGroup/Attacks/AttackCooldown



func _ready():
	animation_tree.active = true
	disable_hitboxes()
	$SlideCollision.disabled = true

func update_animation():
	if is_attacking or is_healing:
		return
	
	if is_sliding:
		playback.travel("slide")
		return
		
	if not is_on_floor():
		
		if velocity.y < 0 and not is_pogo:
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
	
	if is_dead():
		playback.travel("dead")
		return

	get_input()
	

	if Input.is_action_just_pressed("item_1"):
		heal(20)

	
	
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_floor():
		jumps_remaining = MAX_JUMPS
		wall_jumps = 1

	if Input.is_action_just_pressed("jump") and jumps_remaining > 0:
		normal_jump()

	if Input.is_action_just_pressed("jump") and is_on_wall():
		wall_jump()

	handle_attack_hitboxes()

	if Input.is_action_just_pressed("attack_1"):
		attack()

	if Input.is_action_just_pressed("slide") and is_on_floor():
		slide()

	if not is_sliding:

		if direction != 0:
			velocity.x = move_toward(
				velocity.x,
				direction * SPEED,
				ACCELERATION * delta
			)
		else:
			velocity.x = move_toward(
				velocity.x,
				0,
				FRICTION * delta
			)

	if direction != 0:
		$FlipGroup.scale.x = -1 if direction < 0 else 1

	update_animation()

	move_and_slide()

func slide():

	if is_sliding:
		return

	if direction == 0:
		return

	is_sliding = true

	var slide_dir = sign(direction)

	velocity.x = slide_dir * SPEED * 2.0

	playback.travel("slide")

	await get_tree().create_timer(0.35).timeout

	is_sliding = false
	
func attack():
	if not is_attack_ready:
		return
	is_attack_ready = false
	attack_cooldown_timer.start(attack_cooldown_time)
	if Input.is_action_pressed("up"):
		do_upper_attack()

	elif Input.is_action_pressed("down") and not is_on_floor():
		do_lower_attack()
	else:
		do_normal_attack()

func do_upper_attack():
	pass

func do_lower_attack():
	is_attacking = true
	playback.travel("attack_down")

	lower_attack_area.monitoring = true
	await get_tree().physics_frame

	for body in lower_attack_area.get_overlapping_bodies():
		print(body.get_groups())

		if body.has_method("hit"):
			body.hit(get_player_damage())
			pogo_jump()

		if body.is_in_group("jumpable") and velocity.y >= 0:
			pogo_jump()

	lower_attack_area.monitoring = false
	is_attacking = false

func do_normal_attack():
	is_attacking = true
	playback.travel("attack")
	
	for body in vertical_attack_area.get_overlapping_bodies():
		if body.has_method("hit"):
			body.hit(get_player_damage())
	

func pogo_jump():
	is_pogo = true
	jump()
	jumps_remaining = MAX_JUMPS
	
func wall_jump():
	if wall_jumps > 0:
		jump()
		wall_jumps -= 1
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

func on_start_slide():
	$StandingCollision.disabled = true
	$SlideCollision.disabled = false
func on_end_slide():
	$StandingCollision.disabled = false
	$SlideCollision.disabled = true
	is_sliding = false


func heal(amount):
	is_healing = true
	playback.travel("heal")

	Globals.players_health += amount
	
	if Globals.players_health > Globals.max_players_health:
		Globals.players_health = Globals.max_players_health
	
	print("players hp: ", Globals.players_health)



func heal_end():
	print("heal endd")
	is_healing = false


func parry(attacker):

	if attacker == null:
		return

	print("parry")
	

	var dir = sign(global_position.x - attacker.global_position.x)
	if dir == 0:
		dir = -1

	velocity.x = dir * 180
	velocity.y = 0

	is_sliding = true

	var tween = create_tween()

	modulate = Color(1.4, 1.4, 1.4, 1.0)

	tween.tween_property(
		self,
		"modulate",
		Color(1, 1, 1, 1),
		0.15
	)

	await get_tree().create_timer(0.12).timeout
	is_sliding = false

func hit(amount: int, attacker = null):

	if is_dead():
		return

	if is_attacking and attacker != null:
		if "is_attacking" in attacker and attacker.is_attacking:
			parry(attacker)

		if "velocity" in attacker:

			var dir = sign(attacker.global_position.x - global_position.x)
			if dir == 0:
				dir = 1

			attacker.velocity = Vector2(dir * 220, 0)

			if "is_hostile" in attacker:
				attacker.is_hostile = false

				await get_tree().create_timer(0.15).timeout
				attacker.is_hostile = true
			return


	Globals.players_health -= amount
	Globals.players_health = max(Globals.players_health, 0)


	is_attacking = false
	is_sliding = false
	is_healing = false
	is_pogo = false
	
	playback.travel("hit")


	var hit_dir = -sign($FlipGroup.scale.x)
	velocity.x = hit_dir * 360
	velocity.y = -120

	modulate = Color(1.8, 0.3, 0.3, 1.0)

	var tween = create_tween()
	tween.tween_property(
		self,
		"modulate",
		Color(1, 1, 1, 1),
		0.15
	)
	
func is_dead():
	return Globals.players_health < 1
func get_player_damage():
	return Globals.player_damage
func set_player_damage(amount):
	Globals.player_damage = amount

func pogo_end():
	is_pogo = false
		


func _on_attack_cooldown_timeout():
	print("attack ready")
	is_attack_ready = true
