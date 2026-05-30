extends CharacterBody2D
class_name Moon
enum State { DASHING, IDLE }

@export var dash_speed := 1000.0
@export var pause_between_dashes := 0.05
@export var is_hostile := false
@export var bounce_toward_player_chance := 0.45
@export var random_angle_variance := 0.6

@onready var lasers_node: Node2D = $Lasers
@onready var lasers: Array[MoonLaser] = []
@export var laser_attack_duration := 0.0
@export var laser_attack_rotation := deg_to_rad(30.0)
@export var laser_sweep_speed_ratio := 1.0

var state: State = State.IDLE
var is_laser_attacking := false
var _laser_tween: Tween
var _laser_was_hostile := false
var dir := Vector2.RIGHT
var pause_timer := 0.0
var collision_lock := 0.0
var player: Node2D

@onready var sprite = $"."

@onready var damage_area: Area2D = $DamageArea

func _ready():
	player = get_tree().get_first_node_in_group("player")
	damage_area.monitoring = false
	for child in lasers_node.get_children():
		if child is MoonLaser:
			lasers.append(child)
	_disable_all_lasers()

func _physics_process(delta):
	if is_laser_attacking or not is_hostile:
		return

	collision_lock -= delta

	match state:
		State.IDLE:
			pause_timer -= delta
			if pause_timer <= 0.0:
				_start_dash()

		State.DASHING:
			var collision = move_and_collide(dir * dash_speed * delta)
			sprite.rotation += 10.0 * delta

			if collision and collision_lock <= 0.0:
				collision_lock = 0.12
				_handle_collision(collision)
				state = State.IDLE
				pause_timer = pause_between_dashes

func _start_dash():
	if player == null:
		dir = dir.rotated(randf_range(-1.0, 1.0))
	else:
		var target = player.global_position + Vector2(
			randf_range(-80, 80),
			randf_range(-60, 60)
		)

		var desired = (target - global_position).normalized()

		dir = dir.lerp(desired, 0.6).normalized()


	state = State.DASHING

func _handle_collision(collision: KinematicCollision2D):
	var normal = collision.get_normal()
	global_position += normal * 2.0

	var bounce_dir = dir.bounce(normal).normalized()

	if player and randf() < bounce_toward_player_chance:
		var to_player = (player.global_position - global_position).normalized()
		dir = bounce_dir.lerp(to_player, 0.5).normalized()
	else:
		dir = bounce_dir

func enter_hostile_mode():
	is_hostile = true
	state = State.IDLE
	pause_timer = 0.3
	damage_area.monitoring = true

func appear():
	modulate.a = 0.0
	var t = create_tween()
	t.tween_property(self, "modulate:a", 1.0, 2.5)

func normal():
	is_hostile = false
	state = State.IDLE
	velocity = Vector2.ZERO
	damage_area.monitoring = false
	cancel_laser_attack()
	_disable_all_lasers()
	
func perform_laser_attack(attack_direction = 1.0):
	if is_laser_attacking or lasers.is_empty():
		return

	_disable_all_lasers()
	is_laser_attacking = true
	_laser_was_hostile = is_hostile
	is_hostile = false
	state = State.IDLE
	damage_area.monitoring = false

	for laser in lasers:
		laser.is_casting = true

	var start_rotation := rotation
	var target_rotation: float = start_rotation + laser_attack_rotation * attack_direction
	var duration := _get_laser_attack_duration()
	_laser_tween = create_tween()
	_laser_tween.tween_property(
		self,
		"rotation",
		target_rotation,
		duration
	)

	await _laser_tween.finished

	_disable_all_lasers()

	is_laser_attacking = false
	is_hostile = _laser_was_hostile
	if is_hostile:
		damage_area.monitoring = true


func cancel_laser_attack() -> void:
	if not is_laser_attacking:
		return

	if _laser_tween and _laser_tween.is_running():
		_laser_tween.kill()
		_laser_tween = null

	_disable_all_lasers()

	is_laser_attacking = false
	is_hostile = _laser_was_hostile
	if is_hostile:
		damage_area.monitoring = true


func _disable_all_lasers() -> void:
	for laser in lasers:
		laser.is_casting = false


func _get_laser_attack_duration() -> float:
	if laser_attack_duration > 0.0:
		return laser_attack_duration

	var ref_speed := 200.0
	if player and "SPEED" in player:
		ref_speed = float(player.SPEED)

	var sweep_speed := ref_speed * laser_sweep_speed_ratio
	var arc_length := absf(laser_attack_rotation) * _get_laser_sweep_radius()
	return maxf(arc_length / sweep_speed, 0.35)


func _get_laser_sweep_radius() -> float:
	var radius := 0.0
	for laser in lasers:
		radius = maxf(radius, laser.max_length)
	if radius <= 0.0:
		radius = 800.0
	return radius


func _on_damage_area_body_entered(body):
	if not is_hostile or state != State.DASHING:
		return

	if body.is_in_group("player") and "hit" in body:
		body.hit(10, "moon")
		
