extends Action
class_name DashBehindTarget

@export var target_key := "player"
@export var offset := 80.0
@export var speed := 500.0

func on_update(delta):

	var target = blackboard.get_value(target_key)
	if target == null:
		return Status.FAILURE

	var direction_to_agent = sign(agent.global_position.x - target.global_position.x)
	var desired_x = target.global_position.x - direction_to_agent * offset

	var dist = abs(agent.global_position.x - desired_x)

	if dist < 10:
		agent.velocity.x = 0
		return Status.SUCCESS

	var dir = sign(desired_x - agent.global_position.x)

	agent.state = agent.States.DASH
	agent.velocity.x = dir * speed

	return Status.RUNNING
