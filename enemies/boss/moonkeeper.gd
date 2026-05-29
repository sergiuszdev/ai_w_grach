extends CharacterBody2D
class_name Moonkeeper
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var MAX_HEALTH := 1000
@onready var current_hp := MAX_HEALTH

@onready var sprite := $Animations/AnimatedSprite2D
@onready var animation_tree := $Animations/AnimationTree
@onready var playback = animation_tree["parameters/playback"]

@onready var is_attacking := false

@onready var detection := $Attacks/PlayerDetection

@onready var behaviour_tree := $AI/BehaviourTree
var blackboard: Blackboard

signal health_changed(current, max)
@export var moon: CharacterBody2D
enum States {
	IDLE,
	GROUND_ATTACK,
	ANTI_AIR_ATTACK,
	DASH,
	DEATH,
	HIT,
	JUMP,
	JUMP_LOOP,
	LAND,
	RUN,
	WALK,
	AGGRESSIVE_DASH
}

var state: States = States.IDLE

@export var speed := 100.0
@export var dash_speed := 450.0
@export var jump_force := -500.0
@export var phase := 1
var target_player: Node2D = null

var paused := false
var is_dashing := false

func _ready():
	state = States.IDLE
	animation_tree.active = true
	target_player = get_tree().get_first_node_in_group("player")
	print("target_player", target_player)
	blackboard = Blackboard.new()
	blackboard.set_value("player", target_player)
	blackboard.set_value("moon", moon)
	
	blackboard.set_value("last_action", "")
	blackboard.set_value("combo_streak", 0)
	blackboard.set_value("phase", phase)
	
	behaviour_tree.setup(self, blackboard)
	

func _physics_process(delta):
	
	if paused:
		velocity = Vector2.ZERO
		return

	if is_attacking:
		for body in detection.get_overlapping_bodies():
			if body.is_in_group("player") and "hit" in body:
				body.hit(1, self)

	if not is_on_floor():
		velocity.y += (gravity / 2) * delta

	#ai_update(delta)
	update_animation()
	
	
	update_perception()
	behaviour_tree.run(delta)
	move_and_slide()
	
	blackboard.set_value("got_hit", false)


func update_animation():

	if not is_on_floor():
		
		if state == States.AGGRESSIVE_DASH:
			playback.travel("aggressive_dash")
			return

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

		States.GROUND_ATTACK:
			playback.travel("ground_attack")

		States.ANTI_AIR_ATTACK:
			playback.travel("anti_air_attack")

		States.DASH:
			playback.travel("dash")

		States.HIT:
			playback.travel("hit")

		States.LAND:
			playback.travel("land")

		States.DEATH:
			playback.travel("death")
		States.AGGRESSIVE_DASH:
			playback.travel("aggressive_dash")

func jump():

	if not is_on_floor():
		return

	state = States.JUMP
	velocity.y = jump_force



func dash(direction: float):
	
	is_dashing = true
	playback.travel("dash")

	state = States.DASH
	velocity.x = move_toward(velocity.x, direction * dash_speed, dash_speed * 10)

	is_dashing = false


func ground_attack():
	
	state = States.GROUND_ATTACK
	velocity.x = 0

#change it to anti airborne attack
func anti_air_attack():
	state = States.ANTI_AIR_ATTACK
	velocity.x = 0


func hit(amount):
	blackboard.set_value("got_hit", true)
	state = States.HIT
	current_hp -= amount
	emit_signal("health_changed", current_hp, MAX_HEALTH)

func die():
	state = States.DEATH
	velocity = Vector2.ZERO
	
func get_max_health():
	return MAX_HEALTH
	
func get_health():
	return current_hp
	
func trigger_moon():
	if moon == null:
		return
	var moon_tween = create_tween()

	moon_tween.tween_property(
		moon,
		"modulate",
		Color(1, 0, 0, 1),
		0.5
	)

	moon_tween.tween_property(
		moon,
		"modulate",
		Color(1, 1, 1, 1),
		0.5
	)
	
func attack_started():
	is_attacking = true
	
func attack_ended():
	is_attacking = false


func update_perception():

	var player = blackboard.get_value("player")
	if player == null:
		return

	blackboard.set_value("player_pos", player.global_position)
	blackboard.set_value("player_velocity", player.velocity)
	blackboard.set_value("player_in_air", player.global_position.y < global_position.y)
	var dist = global_position.distance_to(player.global_position)
	blackboard.set_value("distance_to_player", dist)

	blackboard.set_value("player_in_range", dist < 200.0)

# methods for btree
#todo remove
#func dash_to_player():
	#if target_player == null:
		#return
#
	#is_dashing = true
	#state = States.DASH
#
	#var dir = sign(target_player.global_position.x - global_position.x)
	#if dir == 0:
		#dir = 1
#
	#velocity.x = dir * dash_speed
#
	#await get_tree().create_timer(0.25).timeout
	#is_dashing = false
#
#func dash_away_from_player():
	#if target_player == null:
		#return
#
	#is_dashing = true
	#state = States.DASH
#
	#var dir = sign(global_position.x - target_player.global_position.x)
	#if dir == 0:
		#dir = -1
#
	#velocity.x = dir * dash_speed
#
	#await get_tree().create_timer(0.25).timeout
	#is_dashing = false
#
#func walk_to_player():
	#if target_player == null:
		#return
#
	#var dir = sign(target_player.global_position.x - global_position.x)
#
	#if dir == 0:
		#dir = 1
#
	#state = States.WALK
#
	#velocity.x = move_toward(
		#velocity.x,
		#dir * speed,
		#speed * 5.0 * get_physics_process_delta_time()
	#)
#
	#sprite.flip_h = velocity.x < 0
# to remove
#func dash_behind_player():
	#if target_player == null:
		#return
#
	#is_dashing = true
	#state = States.DASH
#
	#var behind_offset := 80.0
#
	#var player_pos = target_player.global_position
	#var dir = sign(global_position.x - player_pos.x)
#
	#if dir == 0:
		#dir = 1
#
	#var target_x = player_pos.x + dir * behind_offset
#
	#var dash_dir = sign(target_x - global_position.x)
	#if dash_dir == 0:
		#dash_dir = dir
#
	#velocity.x = dash_dir * dash_speed
	#sprite.flip_h = velocity.x < 0
#
	#await get_tree().create_timer(0.25).timeout
	#is_dashing = false
