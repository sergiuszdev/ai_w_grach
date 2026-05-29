extends Action
class_name Attack1Action

@export var duration := 1.4

var timer := 0.0


func on_start():
	timer = duration

	agent.state = agent.States.GROUND_ATTACK
	agent.velocity.x = 0


func on_update(delta):

	timer -= delta

	if timer <= 0:
		return Status.SUCCESS

	return Status.RUNNING


func on_end():
	agent.is_attacking = false

	if agent.has_method("attack_ended"):
		agent.attack_ended()
