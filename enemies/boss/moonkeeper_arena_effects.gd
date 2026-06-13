extends Node

@onready var camera: Camera2D = $"../Camera2D"
@onready var head: Node2D = $"../Enemy/KeeperHead"
@onready var moon = $"../Enemy/moon"
@onready var second_phase_moon: Marker2D = $"../Enemy/SecondPhaseMoon"
@onready var day_background: CanvasItem = $"../DayBackground"
@onready var night_background: CanvasItem = $"../NightClouds"

func _camera_shake(repetitions: int = 2) -> void:
	if camera == null:
		return

	var offsets := [
		Vector2(8, 0),
		Vector2(-6, 5),
		Vector2(4, -8),
		Vector2(-9, 3),
		Vector2(5, -4),
		Vector2(-3, 7),
		Vector2(7, -2),
		Vector2(-4, -5),
		Vector2(2, 3)
	]

	for _shake_index in repetitions:
		var shake_tween := create_tween()
		for offset in offsets:
			shake_tween.tween_property(
				camera,
				"offset",
				offset,
				randf_range(0.05, 0.08)
			).set_trans(Tween.TRANS_SINE)

		shake_tween.tween_property(
			camera,
			"offset",
			Vector2.ZERO,
			0.15
		).set_trans(Tween.TRANS_SINE)
		await shake_tween.finished

func phase_1_intro() -> void:
	await _camera_shake(2)

	if head != null:
		var head_tween := create_tween()
		head_tween.tween_property(
			head,
			"scale",
			Vector2.ZERO,
			1.0
		).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)

	if day_background != null:
		var day_tween := create_tween()
		day_tween.tween_property(
			day_background,
			"modulate:a",
			0.0,
			2.5
		).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

	await get_tree().create_timer(0.8).timeout

	if moon != null and moon.has_method("appear"):
		moon.appear()

	if night_background != null:
		var night_tween := create_tween()
		night_tween.tween_property(
			night_background,
			"modulate:a",
			1.0,
			3.0
		).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		await night_tween.finished

func phase_2_intro() -> void:
	if moon != null:
		var moon_tween := create_tween()
		moon_tween.tween_property(
			moon,
			"scale",
			Vector2(2.5, 2.5),
			2.0
		)
		if second_phase_moon != null:
			moon_tween.parallel().tween_property(
				moon,
				"global_position",
				second_phase_moon.global_position,
				2.0
			)

	if head != null:
		var head_tween := create_tween()
		head_tween.parallel().tween_property(
			head,
			"modulate:a",
			1.0,
			2.0
		)
		head_tween.parallel().tween_property(
			head,
			"scale",
			Vector2(6.0, 6.0),
			2.0
		)

	if night_background != null:
		var bg_tween := create_tween()
		bg_tween.tween_property(
			night_background,
			"modulate",
			Color(1.0, 1.0, 1.0, 1.0),
			2.5
		)

func phase_3_intro() -> void:
	if moon != null and moon.has_method("normal"):
		moon.normal()

	if moon != null:
		var moon_tween := create_tween()
		moon_tween.tween_property(
			moon,
			"scale",
			Vector2(5.0, 5.0),
			2.0
		)
		if second_phase_moon != null:
			moon_tween.parallel().tween_property(
				moon,
				"global_position",
				second_phase_moon.global_position,
				2.0
			)

	if head != null:
		head.scale = Vector2(6.0, 6.0)

	await _camera_shake(2)

	if head != null:
		var head_tween := create_tween()
		head_tween.parallel().tween_property(
			head,
			"modulate:a",
			1.0,
			0.5
		)
		head_tween.parallel().tween_property(
			head,
			"scale",
			Vector2.ZERO,
			1.0
		)

	if night_background != null:
		var bg_tween := create_tween()
		bg_tween.tween_property(
			night_background,
			"modulate",
			Color(1.8, 0.2, 0.2, 1.0),
			3.0
		)
