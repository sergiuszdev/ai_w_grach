extends Decorator
class_name Cooldown

@export var cooldown := 2.0

var timer := 0.0

func run(delta):

	if not is_active():
		return Status.FAILURE

	if timer > 0.0:
		timer -= delta
		return Status.FAILURE

	var child = get_child_node()

	if child == null:
		return Status.FAILURE

	var result = child.run(delta)

	if result != Status.RUNNING:
		timer = cooldown
	return result


func interrupt():

	var child = get_child_node()

	if child and child.has_method("interrupt"):
		child.interrupt()

	timer = cooldown
