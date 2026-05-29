extends BTLeaf
class_name Wait

@export var wait_time := 1.0

var has_started := false
var timer := 0.0

func run(delta):
	
	if not is_active():
		return Status.FAILURE
	
	if not has_started:
		has_started = true
		timer = wait_time
		
	timer -= delta
	if timer <= 0:
		has_started = false
		return Status.SUCCESS
		
	return Status.RUNNING
