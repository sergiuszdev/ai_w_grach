extends Action
class_name FloatOnMoon

@export var moon_key := "moon"
@export var height := 180.0
@export var follow_speed := 6.0
@export var snap := false

var target_pos := Vector2.ZERO


func on_start():
	var moon = blackboard.get_value(moon_key)
	if moon == null:
		return

	agent.state = agent.States.JUMP_LOOP
	agent.velocity = Vector2.ZERO


func on_update(delta):

	var moon = blackboard.get_value(moon_key)
	if moon == null:
		return Status.FAILURE

	target_pos = moon.global_position + Vector2(0, -height)

	agent.velocity = Vector2.ZERO

	if snap:
		agent.global_position = target_pos
	else:
		agent.global_position = agent.global_position.lerp(
			target_pos,
			follow_speed * delta
		)

	return Status.RUNNING


func on_end():
	agent.velocity = Vector2.ZERO
