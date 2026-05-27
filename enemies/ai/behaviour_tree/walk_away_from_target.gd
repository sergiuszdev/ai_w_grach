extends Action
class_name WalkAwayFromTarget

@export var target_key := "player"
@export var speed := 100.0
@export var safe_distance := 200.0

func on_update(delta):

	var target = blackboard.get_value(target_key)
	if target == null:
		return Status.FAILURE

	var dist = agent.global_position.distance_to(target.global_position)

	if dist >= safe_distance:
		agent.velocity.x = 0
		return Status.SUCCESS

	var dir = sign(agent.global_position.x - target.global_position.x)

	agent.state = agent.States.WALK
	agent.velocity.x = dir * speed

	return Status.RUNNING
