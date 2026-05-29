extends Action
class_name JumpToTarget

@export var target_key := "player"
@export var speed := 500.0
@export var arrival_distance := 20.0
@export var arc_height := 120.0
@export var min_duration := 0.25
@export var max_duration := 1.0

var target_pos := Vector2.ZERO
var start_pos := Vector2.ZERO
var timer := 0.0
var duration := 0.0
var has_target := false


func on_start():
	timer = 0.0
	has_target = false
	agent.velocity = Vector2.ZERO

	var target = blackboard.get_value(target_key)
	if target == null:
		return

	start_pos = agent.global_position
	target_pos = target.global_position
	duration = clamp(start_pos.distance_to(target_pos) / speed, min_duration, max_duration)
	has_target = true

	agent.state = agent.States.JUMP


func on_update(delta):

	if not has_target:
		return Status.FAILURE

	timer += delta
	var t: float = clamp(timer / duration, 0.0, 1.0)

	var pos_x = lerp(start_pos.x, target_pos.x, t)

	var height = sin(t * PI) * arc_height

	agent.global_position.x = pos_x
	agent.global_position.y = lerp(start_pos.y, target_pos.y, t) - height
	agent.velocity = Vector2.ZERO

	if target_pos.x != agent.global_position.x:
		agent.sprite.flip_h = target_pos.x < agent.global_position.x

	if t >= 1.0:
		return Status.SUCCESS

	return Status.RUNNING


func on_end():
	agent.velocity = Vector2.ZERO
