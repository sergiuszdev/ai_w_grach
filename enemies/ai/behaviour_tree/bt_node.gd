extends Node
class_name BTNode
## It disables BTNode. For debug purpose only.
@export var is_enabled := true

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
	if not is_enabled:
		return Status.FAILURE
	return Status.SUCCESS
	
