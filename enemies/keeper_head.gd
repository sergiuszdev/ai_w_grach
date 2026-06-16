extends Node2D
var player: CharacterBody2D
	
	
	
func _ready():
	player = get_tree().get_first_node_in_group("player")		
func _process(_delta):
	if player == null:
		$AnimatedSprite2D.play("towards")
		return
		
	var to_player = player.global_position - global_position

	$AnimatedSprite2D.flip_h = to_player.x < 20
	$Frame0000.flip_h = to_player.x < 20
	if to_player.y > 0:
		$AnimatedSprite2D.play("down")
	elif to_player.y < 0:
		$AnimatedSprite2D.play("up")
	else:
		$AnimatedSprite2D.play("towards")
