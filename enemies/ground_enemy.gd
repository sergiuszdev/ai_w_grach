extends CharacterBody2D
class_name GroundEnemy

var player

@export var speed := 100.0
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
enum Facing { LEFT, RIGHT }

@export var facing: Facing = Facing.RIGHT
func _ready():
	player = get_tree().get_first_node_in_group("player")
	scale.x = -1 if facing == Facing.LEFT else 1
func get_player_direction():
	if player == null:
		return Vector2.ZERO
	return (player.global_position - global_position).normalized()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func _physics_process(delta):

	apply_gravity(delta)
	ai_update(delta)
	move_and_slide()
	update_animation()


func ai_update(delta):
	pass

func update_animation():
	pass
