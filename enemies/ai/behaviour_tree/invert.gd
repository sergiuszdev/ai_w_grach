@icon("res://icons/at-sign.svg")

extends Decorator
class_name Invert

func run(delta):
	
	var child = get_child_node()

	if child == null:
		return Status.FAILURE

	var result = child.run(delta)
	
	match result:
		Status.SUCCESS:
			return Status.FAILURE
			
		Status.FAILURE:
			return Status.SUCCESS
			
		Status.RUNNING:
			return Status.RUNNING
