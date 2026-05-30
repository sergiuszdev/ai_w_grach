extends Action
class_name BlackAggressiveDash


@export var target_key := "player"
@export var speed := 360.0
@export var max_duration := 1.4
@export var hit_damage := 2
@export var hit_radius := 55.0

var direction := 1.0
var timer := 0.0
var hit_targets := {}


func on_start():
	timer = max_duration
	hit_targets.clear()

	var target = blackboard.get_value(target_key)
	if target == null:
		direction = -1.0 if agent.sprite.flip_h else 1.0
	else:
		direction = sign(target.global_position.x - agent.global_position.x)
		if direction == 0:
			direction = -1.0 if agent.sprite.flip_h else 1.0

	agent.state = agent.States.AGGRESSIVE_DASH
	agent.velocity.x = 0
	agent.attack_started()


func on_update(delta: float) -> Status:
	timer -= delta

	if timer <= 0.0 or agent.is_on_wall():
		return Status.SUCCESS

	agent.velocity.x = direction * speed
	_check_hits()

	return Status.RUNNING


func _check_hits():
	var space = agent.get_world_2d().direct_space_state

	var shape := CircleShape2D.new()
	shape.radius = hit_radius

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D.IDENTITY.translated(agent.global_position)
	query.collide_with_bodies = true
	query.exclude = [agent]

	var results = space.intersect_shape(query, 32)

	for r in results:
		var body = r.collider

		if body == null:
			continue

		if hit_targets.has(body):
			continue

		if body.has_method("hit"):
			body.hit(hit_damage, agent)

		hit_targets[body] = true


func on_end():
	agent.velocity.x = 0
	agent.attack_ended()

	if agent.is_on_floor():
		agent.state = agent.States.IDLE
	else:
		agent.state = agent.States.JUMP_LOOP
