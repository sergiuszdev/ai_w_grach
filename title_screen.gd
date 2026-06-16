extends Node



func enter_game():
	print("on game enter")
	#Globals.goto_scene("res://main_game.tscn")
	
	Globals.goto_scene("uid://diy155ng0r2tq")
	pass

func exit():
	print("on exit")
	get_tree().quit()


func _on_start_game_pressed():
	enter_game()
	
	


func _on_quit_pressed():
	exit()
