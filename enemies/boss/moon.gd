extends Sprite2D

var moon_rolling := false

var moon_speed := 20.0
@onready var moon = $"."


func _process(delta):
	if moon_rolling:
		moon.rotation_degrees += moon_speed * 60.0 * delta

func appear():
	var moon_tween = create_tween()

	moon_tween.tween_property(
		moon,
		"modulate:a",
		1.0,
		3.0
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func hostile_mode(new_position):
	moon_rolling = true

	var moon_tween = create_tween()

	moon_tween.tween_property(
		moon,
		"global_position",
		new_position,
		2.0
	)

func normal():
	moon_rolling = false
	
func scale_up(scale_size):
	var tween = create_tween()

	tween.tween_property(
		moon,
		"scale",
		Vector2(scale_size, scale_size),
		3.0
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
