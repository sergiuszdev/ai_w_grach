extends Condition

@export var phase_required := 1

func check_condition() -> bool:
	return agent.blackboard.get_value("phase") == phase_required
