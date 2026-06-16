extends Node2D


func _on_right_level_body_entered(body):
	if body.is_in_group("player"):
		Globals.goto_scene("uid://bnf3uwomebwrs")


func _on_left_level_body_entered(body):
	if body.is_in_group("player"):
		Globals.goto_scene("uid://eyghx6bknct")
