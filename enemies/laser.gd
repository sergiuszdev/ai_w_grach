@tool
extends RayCast2D
class_name MoonLaser

## Beam extension speed in pixels per second. Slightly below player run speed by default.
@export var cast_speed := 420.0
@export var max_length := 1400.0
@export var start_distance := 0.0
@export var growth_time := 0.35
@export var color := Color(0.25, 0.45, 0.95, 1.0): set = set_color
@export var damage := 10

@export var is_casting := false: set = set_is_casting

var tween: Tween = null
var hit_targets := {}

@onready var line_2d: Line2D = $Line2D
@onready var line_width := line_2d.width
@onready var beam_particles: GPUParticles2D = $Line2D/GPUParticles2D


func _ready() -> void:
	set_color(color)
	enabled = is_casting
	set_is_casting(is_casting)
	_reset_beam_visuals()


func _physics_process(delta: float) -> void:
	target_position.x = move_toward(
		target_position.x,
		max_length,
		cast_speed * delta
	)

	var laser_start := _laser_start()
	var laser_end := target_position
	force_raycast_update()

	if is_colliding():
		laser_end = to_local(get_collision_point())
		_try_damage_collider(get_collider())

	_update_beam_visuals(laser_start, laser_end)


func set_is_casting(new_value: bool) -> void:
	if is_casting == new_value:
		return
	is_casting = new_value

	enabled = is_casting
	set_physics_process(is_casting)

	if not line_2d:
		return

	if is_casting:
		hit_targets.clear()
		target_position = Vector2.ZERO
		_reset_beam_visuals()
		appear()
	else:
		disappear()


func appear() -> void:
	line_2d.visible = true
	line_2d.width = 0.0
	if beam_particles:
		beam_particles.emitting = true


func disappear() -> void:
	hit_targets.clear()
	target_position = Vector2.ZERO

	if beam_particles:
		beam_particles.emitting = false

	if tween and tween.is_running():
		tween.kill()
		tween = null

	_reset_beam_visuals()
	line_2d.visible = false


func set_color(new_color: Color) -> void:
	color = new_color
	if line_2d:
		line_2d.modulate = new_color
	if beam_particles and beam_particles.process_material is ParticleProcessMaterial:
		beam_particles.process_material.color = new_color


func _laser_start() -> Vector2:
	return Vector2.RIGHT * start_distance


func _reset_beam_visuals() -> void:
	var laser_start := _laser_start()
	line_2d.points[0] = laser_start
	line_2d.points[1] = laser_start
	line_2d.width = 0.0
	if beam_particles:
		beam_particles.position = laser_start
		if beam_particles.process_material is ParticleProcessMaterial:
			beam_particles.process_material.emission_box_extents.x = 0.0


func _update_beam_visuals(laser_start: Vector2, laser_end: Vector2) -> void:
	line_2d.points[0] = laser_start
	line_2d.points[1] = laser_end

	var beam_length := laser_start.distance_to(laser_end)
	var width_ratio := clampf(beam_length / 16.0, 0.0, 1.0)
	line_2d.width = line_width * width_ratio

	if not beam_particles:
		return

	if beam_length <= 1.0:
		beam_particles.position = laser_start
		return

	var midpoint := laser_start + (laser_end - laser_start) * 0.5
	beam_particles.position = midpoint
	if beam_particles.process_material is ParticleProcessMaterial:
		beam_particles.process_material.emission_box_extents.x = beam_length * 0.5


func _try_damage_collider(collider: Object) -> void:
	if not is_casting or not enabled:
		return
	if collider == null or hit_targets.has(collider):
		return
	if target_position.x < start_distance + 24.0:
		return
	var beam_length := _laser_start().distance_to(to_local(get_collision_point()))
	if beam_length < start_distance + 32.0:
		return
	if collider.is_in_group("player") and collider.has_method("hit"):
		collider.hit(damage, "laser")
		hit_targets[collider] = true
