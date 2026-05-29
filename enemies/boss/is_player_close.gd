extends Condition

@export var distance := 200.0

func check_condition() -> bool:
	
	var player_dist: float =  blackboard.get_value("distance_to_player")
	return player_dist < distance
