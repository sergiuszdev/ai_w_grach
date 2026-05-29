extends Action
class_name AntiAirAttackAction

@export var duration := 1.4666667

var timer := 0.0

func on_start():
	timer = duration

	agent.state = agent.States.ANTI_AIR_ATTACK
	agent.velocity = Vector2.ZERO

func on_update(delta: float) -> Status:
	timer -= delta

	if timer <= 0:
		return Status.SUCCESS

	return Status.RUNNING

func on_end():
	agent.attack_ended()
	agent.state = agent.States.IDLE
