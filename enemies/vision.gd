extends Area2D

signal player_detected(body: CharacterBody2D)
signal player_lost()

@onready var special_collision: CollisionPolygon2D = $VisionShape
@onready var raycasts = [$RayCast2D, $RayCast2D2, $RayCast2D3]

var player: CharacterBody2D = null
var seeing_player := false
var lost_timer := 0.0
var lost_delay := 2.0
var player_in_area := false

func _process(delta):
	if player == null:
		return

	_update_rays(player)
	
	var dist := global_position.distance_to(player.global_position)
	var too_close_for_rays := player_in_area and dist<32
	
	var detected := _check_raycast_hit() or too_close_for_rays

	if detected:
		lost_timer = 0.0
		if not seeing_player:
			seeing_player = true
			player_detected.emit(player)
	else:
		lost_timer += delta
		if lost_timer >= lost_delay:
			seeing_player = false
			player = null
			player_in_area = false
			player_lost.emit()

func _update_rays(target: CharacterBody2D):
	for raycast: RayCast2D in raycasts:
		raycast.look_at(target.global_position)

func _check_raycast_hit() -> bool:
	for raycast: RayCast2D in raycasts:
		raycast.force_raycast_update()
		if raycast.is_colliding():
			if raycast.get_collider() == player:
				return true
	return false

func _on_body_entered(body: Node2D):
	if body.is_in_group("player") and player == null:
		player = body
		player_in_area = true
		lost_timer = 0.0

func set_color(color):
	special_collision.modulate = color


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = false
		lost_timer = 0.0
