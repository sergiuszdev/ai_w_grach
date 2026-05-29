@icon("res://icons/mouse-pointer.svg")
extends BTNode
class_name Selector

var current_index := 0


func run(delta: float) -> Status:

	if not is_active():
		return Status.FAILURE

	var child_count = get_child_count()

	if child_count == 0:
		return Status.FAILURE

	if current_index >= child_count:
		current_index = 0

	while current_index < child_count:

		var child: BTNode = get_child(current_index)
		var result = child.run(delta)

		match result:

			Status.SUCCESS:
				current_index = 0
				return Status.SUCCESS

			Status.RUNNING:
				return Status.RUNNING

			Status.FAILURE:
				current_index += 1

	current_index = 0
	return Status.FAILURE


func interrupt():

	if current_index < get_child_count():
		get_child(current_index).interrupt()

	current_index = 0
