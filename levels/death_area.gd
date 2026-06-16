extends Area2D


func _on_body_entered(body):
	if "hit" in body:
		body.hit(1000000000)
