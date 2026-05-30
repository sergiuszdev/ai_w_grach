extends Action
class_name ActivateMoonAttack

@export var target_key := "moon"
@export var player_key := "player"
@export var float_height := 1.0
@export var follow_speed := 6.0

var moon: Moon
var attack_started := false


func on_start() -> void:
	moon = blackboard.get_value(target_key)
	attack_started = false

	if moon == null:
		return

	agent.state = agent.States.JUMP_LOOP
	agent.velocity = Vector2.ZERO

	var direction := _pick_sweep_direction()
	moon.perform_laser_attack(direction)
	attack_started = moon.is_laser_attacking


func on_update(delta: float) -> int:
	if moon == null or not attack_started:
		return Status.FAILURE

	_keep_agent_on_moon(delta)

	if moon.is_laser_attacking:
		return Status.RUNNING

	return Status.SUCCESS


func on_interrupt() -> void:
	if moon and moon.is_laser_attacking:
		moon.cancel_laser_attack()


func on_end() -> void:
	attack_started = false
	agent.velocity = Vector2.ZERO


func _keep_agent_on_moon(delta: float) -> void:
	var target_pos := moon.global_position + Vector2(0, -float_height)
	agent.global_position = agent.global_position.lerp(target_pos, follow_speed * delta)
	agent.velocity = Vector2.ZERO


func _pick_sweep_direction() -> float:
	var player = blackboard.get_value(player_key)
	if player == null:
		return [-1.0, 1.0].pick_random()

	var to_player_angle := moon.global_position.angle_to_point(player.global_position)
	var angle_diff := angle_difference(to_player_angle, moon.rotation)
	if is_zero_approx(angle_diff):
		return [-1.0, 1.0].pick_random()

	return signf(angle_diff)
