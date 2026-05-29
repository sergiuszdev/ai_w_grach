@icon("res://icons/circle-question-mark.svg")
extends BTLeaf
class_name Condition

var interrupted := false

func check_condition() -> bool:
	return false


func run(delta: float) -> Status:
	if not is_active():
		return Status.FAILURE

	if interrupted:
		interrupted = false
		return Status.INTERRUPTED

	if check_condition():
		return Status.SUCCESS

	return Status.FAILURE


func interrupt():
	interrupted = true
