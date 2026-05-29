@icon("res://icons/refresh-cw-red.svg")
extends Decorator
class_name RepeatUntilFailure


func run(delta: float) -> int:
	if not is_active():
		return Status.FAILURE
	var child = get_child_node()

	if child == null:
		return Status.FAILURE

	var result = child.run(delta)

	if result == Status.INTERRUPTED:
		return Status.INTERRUPTED

	if result == Status.FAILURE:
		return Status.SUCCESS

	return Status.RUNNING
