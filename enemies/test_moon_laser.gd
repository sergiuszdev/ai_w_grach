extends Node2D


@onready var moon = $Moon


func _ready():
	pass
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		moon.perform_laser_attack(1.0)
	if event is InputEventMouseButton \
			and event.pressed \
			and event.button_index == MOUSE_BUTTON_RIGHT:
		moon.perform_laser_attack(-1.0)
