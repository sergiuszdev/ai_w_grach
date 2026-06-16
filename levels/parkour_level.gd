extends Node2D


func _on_go_to_spawn_body_entered(body):
	if body.is_in_group("player"):
		Globals.goto_scene("uid://diy155ng0r2tq")
