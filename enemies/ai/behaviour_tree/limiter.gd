@icon("res://icons/hash.svg")
extends Decorator
class_name Limiter

@export var limit := 1

var counter := 0


func run(delta: float) -> int:
	if not is_active():
		return Status.FAILURE
	if counter >= limit:
		return Status.FAILURE

	var child = get_child_node()

	if child == null:
		return Status.FAILURE

	var result = child.run(delta)

	if result == Status.SUCCESS:
		counter += 1

	return result
