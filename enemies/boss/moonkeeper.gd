extends CharacterBody2D
class_name Moonkeeper
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var MAX_HEALTH := 1600
@onready var current_hp := MAX_HEALTH

@onready var sprite := $Animations/AnimatedSprite2D
@onready var animation_tree := $Animations/AnimationTree
@onready var playback = animation_tree["parameters/playback"]

@onready var is_attacking := false

@onready var detection := $Attacks/PlayerDetection
@onready var attacks := $Attacks
@onready var attack_area := $Attacks/Area_1

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
var _current_anim := ""
var _attack_hit_targets := {}

func _ready():
	state = States.IDLE
	animation_tree.active = true

	target_player = get_tree().get_first_node_in_group("player")

	blackboard = Blackboard.new()

	blackboard.set_value("player", target_player)
	blackboard.set_value("moon", moon)

	blackboard.set_value("last_action", "")
	blackboard.set_value("combo_streak", 0)
	blackboard.set_value("phase", phase)

	blackboard.set_value("player_actions", [])
	blackboard.set_value("player_action_counts", {})

	if target_player:
		target_player.player_action.connect(_on_player_action)

	behaviour_tree.setup(self, blackboard)

	attack_area.collision_mask = 1
	attack_area.monitoring = false

func _physics_process(delta):
	
	if state == States.DEATH:
		update_animation()
		return
	
	if paused:
		velocity = Vector2.ZERO
		return

	if is_attacking:
		_apply_attack_hits(detection)
		_apply_attack_hits(attack_area)

	if not is_on_floor():
		velocity.y += (gravity / 2) * delta

	#ai_update(delta)
	update_animation()
	
	
	update_perception()
	behaviour_tree.run(delta)
	move_and_slide()
	
	blackboard.set_value("got_hit", false)


func update_animation():
	var anim_name := _get_anim_name()
	if anim_name != _current_anim:
		playback.travel(anim_name)
		_current_anim = anim_name


func _get_anim_name() -> String:
	if not is_on_floor():
		if state == States.AGGRESSIVE_DASH:
			return "aggressive_dash"
		if velocity.y < 0:
			return "jump"
		return "jump_loop"

	match state:
		States.IDLE:
			return "idle"
		States.WALK:
			return "walk"
		States.RUN:
			return "run"
		States.GROUND_ATTACK:
			return "ground_attack"
		States.ANTI_AIR_ATTACK:
			return "anti_air_attack"
		States.DASH:
			return "dash"
		States.HIT:
			return "hit"
		States.LAND:
			return "land"
		States.DEATH:
			return "death"
		States.AGGRESSIVE_DASH:
			return "aggressive_dash"
		_:
			return "idle"


func set_facing(face_left: bool) -> void:
	sprite.flip_h = face_left
	attacks.scale.x = -1.0 if face_left else 1.0


func set_facing_toward(world_x: float) -> void:
	var dir := signf(world_x - global_position.x)
	if dir != 0.0:
		set_facing(dir < 0.0)


func _apply_attack_hits(area: Area2D) -> void:
	for body in area.get_overlapping_bodies():
		if not body.is_in_group("player"):
			continue
		if _attack_hit_targets.has(body):
			continue
		if body.has_method("hit"):
			body.hit(5, self)
			_attack_hit_targets[body] = true

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
	_attack_hit_targets.clear()
	attack_area.monitoring = true

func attack_ended():
	is_attacking = false
	attack_area.monitoring = false


func _on_player_action(action_name: String, context: Dictionary):

	var history = blackboard.get_value("player_actions", [])

	history.append(action_name)

	if history.size() > 20:
		history.pop_front()

	blackboard.set_value("player_actions", history)

	var counts = blackboard.get_value("player_action_counts", {})

	counts[action_name] = counts.get(action_name, 0) + 1

	blackboard.set_value("player_action_counts", counts)

	print("Player action:", action_name)
	print("History:", history)

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
