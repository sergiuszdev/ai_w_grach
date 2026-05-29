extends Condition
func check_condition() -> bool:
	return agent.blackboard.get_value("player_in_air", false)
