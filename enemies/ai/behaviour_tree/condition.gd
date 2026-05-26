@icon("res://icons/circle-question-mark.svg")

extends BTLeaf
class_name Condition
func check_condition() -> bool:
	return false

func run(delta: float) -> Status:
	if check_condition():
		return Status.SUCCESS

	return Status.FAILURE
