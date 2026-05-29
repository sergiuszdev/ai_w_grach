@icon("res://icons/asterisk.svg")
extends BTNode
class_name Interruptable

@export var interrupt_distance := 500.0
@export var interrupt_on_hit := true

var interrupted := false


func run(delta):

	if interrupted:
		interrupt_child()
		interrupted = false
		return Status.INTERRUPTED

	if should_interrupt():
		interrupt_child()
		return Status.INTERRUPTED

	if get_child_count() == 0:
		return Status.FAILURE

	return get_child(0).run(delta)


func should_interrupt() -> bool:

	var player = blackboard.get_value("player")

	if player == null:
		return true

	var dist = agent.global_position.distance_to(
		player.global_position
	)

	if dist > interrupt_distance:
		return true

	if interrupt_on_hit:
		if blackboard.get_value("got_hit", false):
			return true

	return false


func interrupt_child():

	if get_child_count() == 0:
		return

	var child = get_child(0)

	if child.has_method("interrupt"):
		child.interrupt()
