@icon("res://icons/brackets.svg")
extends BTNode
class_name BTSequence

func run(delta):
	for child in get_children():
		var result = child.run(delta)
		if result != Status.SUCCESS:
			return result
	return Status.SUCCESS
