extends Action
class_name AntiAirAttackAction

@export var windup_time := 0.2
@export var attack_time := 0.3
@export var recovery_time := 0.2

var timer := 0.0
var phase := 0

func on_start():
	timer = windup_time
	phase = 0

	agent.state = agent.States.ANTI_AIR_ATTACK
	agent.velocity = Vector2.ZERO
	agent.attack_started()

func on_update(delta: float) -> Status:
	timer -= delta

	match phase:
		0:
			if timer <= 0:
				phase = 1
				timer = attack_time

		1:
			if timer <= 0:
				phase = 2
				timer = recovery_time

		2:
			if timer <= 0:
				return Status.SUCCESS

	return Status.RUNNING

func on_end():
	agent.attack_ended()
	agent.state = agent.States.IDLE
