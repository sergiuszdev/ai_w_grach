extends Action
class_name DashBehindTarget

@export var target_key := "player"
@export var offset := 100.0
@export var speed := 600.0
@export var max_duration := 0.5
@export var arrival_distance := 12.0

var target_x := 0.0
var timer := 0.0


func on_start():

	timer = max_duration

	var target = blackboard.get_value(target_key)

	if target == null:
		return

	var side = sign(target.global_position.x - agent.global_position.x)

	if side == 0:
		side = 1.0

	target_x = target.global_position.x + side * offset

	agent.state = agent.States.DASH


func on_update(delta):

	timer -= delta

	if timer <= 0.0:
		return Status.SUCCESS

	var distance_to_goal = abs(target_x - agent.global_position.x)

	if distance_to_goal <= arrival_distance:
		return Status.SUCCESS

	var dir = sign(target_x - agent.global_position.x)

	agent.velocity.x = dir * speed

	return Status.RUNNING


func on_end():

	agent.velocity.x = 0
