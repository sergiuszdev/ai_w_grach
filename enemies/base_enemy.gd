extends CharacterBody2D
class_name BaseEnemy


@export var speed := 100.0
var player: Node2D

#do implementacji BaseEnemy w GroundEnemy, FlyingEnemy, BossEnemy(?)

func _ready():
	player = get_tree().get_first_node_in_group("player")

func get_player_direction() -> Vector2:
	if player == null:
		return Vector2.ZERO
	return (player.global_position - global_position).normalized()

func apply_gravity(delta):
	var g = ProjectSettings.get_setting("physics/2d/default_gravity")
	if not is_on_floor():
		velocity.y += g * delta
