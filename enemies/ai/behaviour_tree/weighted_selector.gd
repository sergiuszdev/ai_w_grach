extends BTNode
class_name WeightedSelector

var current_child: BTNode = null


func run(delta: float) -> Status:

	if not is_active():
		return Status.FAILURE

	if current_child == null:
		current_child = _pick_weighted()

	if current_child == null:
		return Status.FAILURE

	var result := current_child.run(delta)

	if result == Status.RUNNING:
		return Status.RUNNING

	current_child = null

	return result


func _pick_weighted() -> BTNode:

	var total := 0.0

	for child in get_children():
		if "weight" in child:
			total += child.weight
		else:
			total += 1.0

	var pick := randf() * total
	var acc := 0.0

	for child in get_children():
		var w: float = child.weight if "weight" in child else 1.0
		acc += w

		if pick <= acc:
			return child

	return get_child(get_child_count() - 1)


func interrupt():

	if current_child:
		current_child.interrupt()

	current_child = null
