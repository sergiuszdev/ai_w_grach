extends Node2D
class_name DarkForestDoors
enum DoorState {
	OPEN,
	CLOSED
}

@export var door_state: DoorState = DoorState.CLOSED:
	set(value):
		door_state = value
		update_door()


func _ready():
	update_door()


func close_door():
	door_state = DoorState.CLOSED
	update_door()
	

func open_door():
	door_state = DoorState.OPEN
	update_door()

func update_door():

	var is_open = door_state == DoorState.OPEN

	$Open.visible = is_open
	$Closed.visible = !is_open
