@icon("res://icons/square-activity.svg")
extends BTLeaf
class_name Action

var started := false


func on_start():
	
	print(get_path())
	pass

func on_interrupt():
	pass
	
func on_end():
	pass
	
func on_update(delta: float):
	return Status.SUCCESS

func register_action(action_name: String):

	var last: String = blackboard.get_value("last_action", "")
	var streak: int = blackboard.get_value("combo_streak", 0)

	if last == action_name:
		streak += 1
	else:
		streak = 1

	blackboard.set_value("last_action", action_name)
	blackboard.set_value("combo_streak", streak)


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
	print("interrupted")
	if started:
		on_interrupt()
		on_end()
		started = false
