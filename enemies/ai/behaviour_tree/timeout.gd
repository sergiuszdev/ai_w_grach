@icon("res://icons/hourglass.svg")
extends Decorator
class_name Timeout

@export var duration := 1.0

var timer := 0.0


func run(delta: float) -> int:

	if not is_active():
		return Status.FAILURE

	var child = get_child_node()

	if child == null:
		return Status.FAILURE

	timer += delta

	if timer >= duration:
		timer = 0
		return Status.FAILURE

	var result = child.run(delta)

	if result != Status.RUNNING:
		timer = 0

	return result
