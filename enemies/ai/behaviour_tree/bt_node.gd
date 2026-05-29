extends Node
class_name BTNode
## It disables BTNode. For debug purpose only.
@export var is_enabled := true
## Weighs for weighted selector
@export var weight := 1.0
enum Status {
	SUCCESS,
	RUNNING,
	FAILURE,
	SKIPPED,
	ABORTED,
	INTERRUPTED
}

var agent: Node
var blackboard: Blackboard

func setup(_agent: Node, _blackboard: Blackboard):
	agent = _agent
	blackboard = _blackboard

func run(delta: float) -> Status:
	
	if blackboard.get_value("boss_paused", false):
		return Status.RUNNING
	
	if not is_active():
		return Status.FAILURE
	return Status.SUCCESS
	
func interrupt():
	pass

func is_active() -> bool:
	if not is_enabled:
		return false

	var p = get_parent()
	while p != null:
		if p is BTNode and not p.is_enabled:
			return false
		p = p.get_parent()

	return true
