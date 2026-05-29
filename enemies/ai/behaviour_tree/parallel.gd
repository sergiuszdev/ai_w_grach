extends BTNode
class_name Parallel


func run(delta: float) -> int:
	if not is_active():
		return Status.FAILURE
	var all_success := true

	for child in get_children():

		var result = child.run(delta)

		match result:

			Status.FAILURE:
				return Status.FAILURE

			Status.RUNNING:
				all_success = false

			Status.SUCCESS:
				pass

			Status.INTERRUPTED:
				interrupt()
				return Status.INTERRUPTED

	if all_success:
		return Status.SUCCESS

	return Status.RUNNING


func interrupt():

	for child in get_children():
		child.interrupt()
