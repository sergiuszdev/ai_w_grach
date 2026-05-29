@icon("res://icons/refresh-cw-blue.svg")

extends Decorator
class_name Repeat


func run(delta: float) -> int:
	if not is_active():
		return Status.FAILURE
	var child = get_child_node()

	if child == null:
		return Status.FAILURE

	var result = child.run(delta)

	if result == Status.INTERRUPTED:
		return Status.INTERRUPTED

	return Status.RUNNING
