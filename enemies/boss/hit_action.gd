extends Action
class_name HitAction

@export var hit_duration := 0.4
var timer := 0.0

func on_start():
	timer = hit_duration
	agent.state = agent.States.HIT
	agent.velocity = Vector2.ZERO
	agent.attack_ended()
	agent.is_attacking = false

func on_update(delta: float) -> Status:
	timer -= delta

	if timer <= 0.0:
		return Status.SUCCESS

	return Status.RUNNING

func on_end():
	agent.state = agent.States.IDLE
