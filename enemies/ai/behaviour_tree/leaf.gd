@icon("res://icons/leaf.svg")

extends BTNode
class_name BTLeaf

@export var method_name: String

func run(delta: float) -> int:
	if agent == null:
		return Status.FAILURE

	if not agent.has_method(method_name):
		return Status.FAILURE

	agent.call(method_name)
	return Status.SUCCESS
