extends Action
class_name WalkToTarget

@export var target_key := "player"
@export var speed := 100.0
@export var stop_distance := 60.0

func on_update(_delta):

	var target = blackboard.get_value(target_key)
	if target == null:
		return Status.FAILURE

	var dist = agent.global_position.distance_to(target.global_position)

	if dist <= stop_distance:
		agent.velocity.x = 0
		agent.state = agent.States.IDLE
		return Status.SUCCESS

	var dir = sign(target.global_position.x - agent.global_position.x)

	if dir != 0 and agent.has_method("set_facing"):
		agent.set_facing(dir < 0)

	agent.state = agent.States.WALK
	agent.velocity.x = dir * speed

	return Status.RUNNING


func on_end():
	agent.velocity.x = 0
	if agent.state == agent.States.WALK:
		agent.state = agent.States.IDLE
