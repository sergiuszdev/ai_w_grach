extends CharacterBody2D

enum State { DASHING, IDLE }

@export var dash_speed := 1000.0
@export var pause_between_dashes := 0.05
@export var is_hostile := false
@export var bounce_toward_player_chance := 0.45
@export var random_angle_variance := 0.6

var state: State = State.IDLE
var dir := Vector2.RIGHT
var pause_timer := 0.0
var collision_lock := 0.0
var player: Node2D

@onready var sprite = $"."

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if not is_hostile:
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

func appear():
	modulate.a = 0.0
	var t = create_tween()
	t.tween_property(self, "modulate:a", 1.0, 2.5)

func normal():
	is_hostile = false
	state = State.IDLE
	velocity = Vector2.ZERO
