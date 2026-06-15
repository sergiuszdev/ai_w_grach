extends CanvasLayer

@onready var is_paused := false
@onready var game_ui := $"."

func _ready():
	pass

func _input(event):
	if event.is_action_pressed("escape_button"):
		if is_paused:
			resume_game()
		else:
			pause_game()
	

func pause_game():
	print("pause")
	game_ui.visible = true
	get_tree().paused = true
	is_paused = true
	
	
func resume_game():
	print("resume_game")
	game_ui.visible = false
	get_tree().paused = false
	is_paused = false
	


func _on_resume_button_pressed():
	resume_game()


func _on_quit_button_pressed():
	get_tree().quit()
#	todo make it to title screen
