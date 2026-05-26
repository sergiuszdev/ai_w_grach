extends Node
class_name BTNode

enum Status {
	SUCCESS,
	RUNNING,
	FAILURE
}

var agent: Node
var blackboard: Blackboard

func setup(_agent: Node, _blackboard: Blackboard):
	agent = _agent
	blackboard = _blackboard

func run(delta: float) -> Status:
	return Status.SUCCESS
	
