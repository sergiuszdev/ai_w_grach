@icon("res://icons/mouse-pointer.svg")
extends BTNode

class_name Selector

var current_index = 0

func run(delta: float) -> Status:
	if not is_enabled:
		return Status.FAILURE
	while current_index < get_child_count():
		var child: BTNode = get_child(current_index)
		var result = child.run(delta)
		
		match result:
			Status.SUCCESS:
				current_index = 0
				return Status.SUCCESS
			
			Status.RUNNING:
				return Status.RUNNING
				
			Status.FAILURE:
				current_index+=1
	current_index = 0
	return Status.FAILURE
