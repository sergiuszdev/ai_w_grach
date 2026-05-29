@icon("res://icons/square-activity.svg")
extends BTLeaf
class_name Action

var started := false


func on_start():
	pass

func on_interrupt():
	pass
	
func on_end():
	pass
	
func on_update(delta: float):
	return Status.SUCCESS




func run(delta: float) -> int:
	if not is_enabled:
		if started:
			on_end()
			started = false
		return Status.FAILURE

	if not started:
		started = true
		on_start()

	var result = on_update(delta)

	if result != Status.RUNNING:
		on_end()
		started = false

	return result
	
func interrupt():

	if started:
		on_interrupt()
		on_end()
		started = false
