extends BTNode
class_name Decorator

func get_child_node():
	if not is_enabled:
		return
	
	if get_child_count() == 0:
		return null
	return get_child(0)
