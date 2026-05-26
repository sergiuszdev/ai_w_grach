@icon("res://icons/brackets.svg")
extends BTNode
class_name BTSequence

var current_index := 0

func run(delta):
	
	
	while current_index < get_child_count():
		var child: BTNode = get_child(current_index)
		var result: Status = child.run(delta)
		
		match result:
			Status.SUCCESS:
				current_index += 1
			Status.RUNNING:
				return Status.RUNNING
			Status.FAILURE:
				current_index = 0
				return Status.FAILURE
	current_index = 0
	return Status.SUCCESS
