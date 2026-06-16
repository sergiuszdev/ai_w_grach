extends Node2D


func _on_spawn_body_entered(body):
	if body.is_in_group("player"):
		Globals.goto_scene("uid://diy155ng0r2tq")


func _on_boss_area_body_entered(body):
	if body.is_in_group("player"):
		Globals.goto_scene("uid://qhds5s681t7k")
