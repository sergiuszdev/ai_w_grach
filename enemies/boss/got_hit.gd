extends Condition
class_name GotHitCondition

func check_condition() -> bool:
	return agent.blackboard.get_value("got_hit", false)
