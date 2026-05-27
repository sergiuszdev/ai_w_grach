extends Condition

func check_condition() -> bool:
	var perc = (agent.get_health() / agent.get_max_health())*100
	return perc >= 70
