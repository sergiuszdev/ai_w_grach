extends BTNode
class_name Decorator

func get_child_node():
	if not is_active():
		return null
	
	if get_child_count() == 0:
		return null
	return get_child(0)
	

func interrupt():
	var child = get_child_node()
	if child != null:
		child.interrupt()
