extends BTNode
class_name ParallelAny


func run(delta: float) -> int:

	var has_running := false

	for child in get_children():

		var result = child.run(delta)

		match result:

			Status.SUCCESS:
				return Status.SUCCESS

			Status.FAILURE:
				return Status.FAILURE

			Status.RUNNING:
				has_running = true

	if has_running:
		return Status.RUNNING

	return Status.FAILURE


func interrupt():

	for child in get_children():
		child.interrupt()
