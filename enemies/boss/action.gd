extends Action
class_name FloatOnTarget

@export var target_key := "player"

@export var hover_height := 120.0
@export var follow_speed := 3.0
@export var max_horizontal_offset := 60.0

func on_start():
	var target = blackboard.get_value(target_key)
	if target == null:
		return

	agent.state = agent.States.JUMP_LOOP


func on_update(delta):

	var target = blackboard.get_value(target_key)
	if target == null:
		return Status.FAILURE

	var target_pos: Vector2 = target.global_position

	# desired floating position (above player + slight tracking)
	var desired_x = target_pos.x
	var desired_y = target_pos.y - hover_height

	# smooth movement (IMPORTANT: no hard teleport)
	agent.global_position.x = lerp(agent.global_position.x, desired_x, follow_speed * delta)
	agent.global_position.y = lerp(agent.global_position.y, desired_y, follow_speed * delta)

	# optional clamp so it doesn't drift too far
	var offset_x = agent.global_position.x - target_pos.x
	if abs(offset_x) > max_horizontal_offset:
		agent.global_position.x = target_pos.x + sign(offset_x) * max_horizontal_offset

	return Status.RUNNING


func on_end():
	pass
