@icon("res://icons/check.svg")
extends Decorator
class_name Succeeder


func run(delta: float) -> int:

	if not is_active():
		return Status.FAILURE

	var child = get_child_node()

	if child == null:
		return Status.SUCCESS

	var result = child.run(delta)

	if result == Status.RUNNING:
		return Status.RUNNING

	if result == Status.INTERRUPTED:
		return Status.INTERRUPTED

	return Status.SUCCESS
