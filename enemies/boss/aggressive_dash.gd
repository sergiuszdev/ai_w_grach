extends Action
class_name AggressiveDash

@export var target_key := "player"
@export var speed := 900.0
@export var max_duration := 0.5
@export var hit_damage := 20
@export var hit_radius := 40.0

var direction := Vector2.ZERO
var start_position := Vector2.ZERO
var target_position := Vector2.ZERO
var target_distance := 0.0
var timer := 0.0
var hit_targets := {}

func on_start():
	timer = max_duration
	hit_targets.clear()
	direction = Vector2.ZERO
	start_position = agent.global_position
	target_position = start_position
	target_distance = 0.0

	var target = blackboard.get_value(target_key)
	if target == null:
		return

	target_position = target.global_position
	var to_target = target_position - start_position
	direction = to_target.normalized()
	target_distance = to_target.length()

	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT if not agent.sprite.flip_h else Vector2.LEFT
		target_distance = speed * max_duration

	agent.state = agent.States.AGGRESSIVE_DASH
	agent.velocity = Vector2.ZERO


func on_update(delta):

	if direction == Vector2.ZERO:
		return Status.FAILURE

	timer -= delta
	if timer <= 0.0:
		return Status.SUCCESS

	var distance_traveled = (agent.global_position - start_position).dot(direction)
	if distance_traveled >= target_distance:
		return Status.SUCCESS

	agent.velocity = direction * speed

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
	agent.velocity = Vector2.ZERO
