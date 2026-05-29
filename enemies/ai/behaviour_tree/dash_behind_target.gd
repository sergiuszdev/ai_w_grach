extends Action
class_name DashBehindTarget

@export var target_key := "player"
@export var offset := 80.0
@export var speed := 500.0
@export var max_duration := 0.6
@export var contact_distance := 45.0

var side := 1.0
var timer := 0.0


func on_start():
	timer = max_duration

	var target = blackboard.get_value(target_key)
	if target == null:
		return

	side = sign(agent.global_position.x - target.global_position.x)
	if side == 0:
		side = 1.0

	agent.state = agent.States.DASH


func on_update(delta):

	var target = blackboard.get_value(target_key)
	if target == null:
		return Status.FAILURE

	if agent.global_position.distance_to(target.global_position) <= contact_distance:
		agent.velocity.x = 0
		return Status.SUCCESS

	timer -= delta
	if timer <= 0:
		agent.velocity.x = 0
		return Status.SUCCESS

	var desired_x = target.global_position.x + side * offset

	var dist = abs(agent.global_position.x - desired_x)

	if dist < 10:
		agent.velocity.x = 0
		return Status.SUCCESS

	var dir = sign(desired_x - agent.global_position.x)

	agent.velocity.x = dir * speed

	return Status.RUNNING


func on_end():
	agent.velocity.x = 0
