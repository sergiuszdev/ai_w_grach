@icon("res://icons/mouse-pointer.svg")
extends BTNode

class_name Selector


func run(delta: float) -> Status:
	
	for child: BTNode in get_children():
		var result = child.run(delta)
		if result != Status.FAILURE:
			return result
		
	return Status.FAILURE
	
