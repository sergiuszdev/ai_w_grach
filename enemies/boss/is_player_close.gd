extends Condition

@export var distance := 200.0

func check_condition() -> bool:
	var player = blackboard.get_value("player")

	if player == null:
		return false

	var is_close = agent.global_position.distance_to(
		player.global_position
	) <= distance
	
	if is_close:
		print("jest blisko")
	else:
		print("nie jest blisko")
	return is_close
