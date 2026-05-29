extends Condition
class_name PlayerInRange

@export var distance := 200.0


func check_condition() -> bool:

	var dist = blackboard.get_value("distance_to_player", INF)
	print("dist ", dist)
	print("range ", distance)
	return dist <= distance
