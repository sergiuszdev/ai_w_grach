extends Condition
class_name IsPlayerAbove

@export var min_height := 40.0
@export var target_key := "player_pos"


func check_condition() -> bool:

	var player_pos = blackboard.get_value(target_key)

	if player_pos == null:
		return false

	return player_pos.y < agent.global_position.y - min_height
