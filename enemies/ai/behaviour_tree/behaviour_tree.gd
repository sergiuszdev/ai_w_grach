@icon("res://icons/network.svg")
extends Node
class_name BehaviourTree

var agent: Node
var blackboard: Blackboard


func setup(_agent: Node, _blackboard: Blackboard):
	agent = _agent
	blackboard = _blackboard

	print("BT setup → blackboard:", blackboard, " agent:", agent)

	for child in get_children():
		_setup_recursive(child)


func _setup_recursive(node: Node):
	if node.has_method("setup"):
		node.setup(agent, blackboard)

	for child in node.get_children():
		_setup_recursive(child)



func run(delta: float):
	for child in get_children():
		if child.has_method("run"):
			child.run(delta)
