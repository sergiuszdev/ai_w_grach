@icon("res://icons/at-sign.svg")
extends Decorator
class_name Invert

var interrupted := false

func run(delta):
	if not is_active():
		return Status.FAILURE

	if interrupted:
		interrupted = false
		var child = get_child_node()
		if child:
			child.interrupt()
		return Status.INTERRUPTED

	var child = get_child_node()
	if child == null:
		return Status.FAILURE

	var result = child.run(delta)

	match result:
		Status.SUCCESS:
			return Status.FAILURE

		Status.FAILURE:
			return Status.SUCCESS

		Status.RUNNING:
			return Status.RUNNING

		Status.INTERRUPTED:
			return Status.INTERRUPTED


func interrupt():
	interrupted = true

	var child = get_child_node()
	if child:
		child.interrupt()
