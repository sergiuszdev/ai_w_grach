@icon("res://icons/square-activity.svg")

extends BTLeaf
class_name Action

var started := false

func on_start():
	pass

func on_update(delta: float):
	return Status.SUCCESS

func on_end():
	pass

func run(delta: float) -> int:
	if not started:
		started = true
		on_start()

	var result = on_update(delta)

	if result != Status.RUNNING:
		on_end()
		started = false

	return result
