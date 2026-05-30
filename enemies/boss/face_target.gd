extends Action
class_name FaceTarget

@export var target_key := "player"
@export var once := false

func on_update(delta):

	var target = blackboard.get_value(target_key)

	if target == null:
		return Status.FAILURE

	var dir = sign(
		target.global_position.x - agent.global_position.x
	)

	if dir != 0 and agent.has_method("set_facing"):
		agent.set_facing(dir < 0)
	elif dir != 0:
		agent.sprite.flip_h = dir < 0
	if once:
		return Status.SUCCESS
	return Status.RUNNING
