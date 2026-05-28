extends Area2D

var player = null
var timer = 0.0

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body
		timer = 0.0
		player.take_damage(10)

func _on_body_exited(body):
	if body.is_in_group("player"):
		player = null
		timer = 0.0

func _process(delta):
	if player:
		timer += delta
		if timer >= 1.0:
			timer = 0.0
			player.take_damage(10)
