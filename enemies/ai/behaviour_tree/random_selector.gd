extends BTNode
class_name RandomSelector

var last_index := -1


func run(delta: float) -> Status:
	print("random selector")
	if not is_active():
		return Status.FAILURE

	if get_child_count() == 0:
		return Status.FAILURE

	if last_index == -1:
		last_index = randi() % get_child_count()

	var child: BTNode = get_child(last_index)
	var result := child.run(delta)

	if result == Status.RUNNING:
		return Status.RUNNING

	last_index = -1

	return result


func interrupt():

	if last_index >= 0 and last_index < get_child_count():
		get_child(last_index).interrupt()

	last_index = -1
