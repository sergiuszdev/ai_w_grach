extends Action
class_name FaceTarget

@export var target_key := "player"


func on_update(delta):

	var target = blackboard.get_value(target_key)

	if target == null:
		return Status.FAILURE

	var dir = sign(
		target.global_position.x - agent.global_position.x
	)

	if dir != 0:
		agent.sprite.flip_h = dir < 0

	return Status.RUNNING
