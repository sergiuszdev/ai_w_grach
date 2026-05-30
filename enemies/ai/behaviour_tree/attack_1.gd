extends Action
class_name Attack1Action

@export var duration := 1.4
@export var hit_start := 0.4
@export var hit_end := 0.9

var timer := 0.0
var elapsed := 0.0


func on_start():
	timer = duration
	elapsed = 0.0
	agent.state = agent.States.GROUND_ATTACK
	agent.velocity.x = 0
	agent.is_attacking = false


func on_update(delta: float) -> Status:
	elapsed += delta
	timer -= delta

	var in_hit_window := elapsed >= hit_start and elapsed < hit_end
	if in_hit_window:
		if not agent.is_attacking:
			agent.attack_started()
	else:
		if agent.is_attacking:
			agent.attack_ended()

	if timer <= 0.0:
		return Status.SUCCESS

	return Status.RUNNING


func on_end():
	if agent.is_attacking:
		agent.attack_ended()
	agent.state = agent.States.IDLE
