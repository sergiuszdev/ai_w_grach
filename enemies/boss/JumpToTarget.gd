extends Action
class_name JumpToPlayer

@export var target_key := "player_pos"
@export var jump_force := -500.0
@export var horizontal_speed := 120.0


func on_start():

	agent.state = agent.States.JUMP

	var player_pos = blackboard.get_value(target_key)

	if player_pos == null:
		return


	var dir = sign(player_pos.x - agent.global_position.x)
	if dir == 0:
		dir = 1

	agent.velocity.y = jump_force
	agent.velocity.x = dir * horizontal_speed


func on_update(delta):
	if agent.is_on_floor():
		return Status.SUCCESS

	return Status.RUNNING
