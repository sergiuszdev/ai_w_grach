extends Node2D


const ENEMY_SCENE = preload("res://enemies/skeleton_warrior.tscn")

# Referencja do miejsca spawnu
@onready var timer_1 = $Timer1
@onready var timer_2 = $Timer2

# Referencje do dwóch różnych punktów spawnu
@onready var spawn_point_1 = $Spawner1
@onready var spawn_point_2 = $Spawner2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_timer_1_timeout() -> void:
	print("Spawn z punktu 1")
	spawn_enemy(spawn_point_1.global_position)


func _on_timer_2_timeout() -> void:
	print("Spawn z punktu 2")
	spawn_enemy(spawn_point_2.global_position)


func _on_spawn_trigger_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		
		timer_1.start() 
		
		$SpawnTrigger.queue_free() 
		
		await get_tree().create_timer(5.0).timeout
		timer_2.start()
		
func spawn_enemy(target_position: Vector2):
	var new_enemy = ENEMY_SCENE.instantiate()
	new_enemy.global_position = target_position
	add_child(new_enemy)
