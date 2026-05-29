extends Action
class_name Attack1Action

@export var windup := 0.25
@export var active := 0.2
@export var recovery := 0.4

var timer := 0.0
var phase := 0


func on_start():
	timer = windup
	phase = 0

	agent.state = agent.States.GROUND_ATTACK
	agent.velocity.x = 0

	if agent.has_method("attack_started"):
		agent.attack_started()


func on_update(delta):

	timer -= delta

	match phase:

		0: # WINDUP
			if timer <= 0:
				phase = 1
				timer = active

				# ENABLE HIT
				agent.is_attacking = true

		1: # ACTIVE HIT WINDOW
			if timer <= 0:
				phase = 2
				timer = recovery

				# DISABLE HIT
				agent.is_attacking = false

				if agent.has_method("attack_ended"):
					agent.attack_ended()

		2: # RECOVERY
			if timer <= 0:
				return Status.SUCCESS

	return Status.RUNNING


func on_end():
	agent.is_attacking = false

	if agent.has_method("attack_ended"):
		agent.attack_ended()
