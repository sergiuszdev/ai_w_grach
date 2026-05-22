extends Node2D

@onready var doors = [$Terrain/Props/RightDoor, $Terrain/Props/LeftDoor]
@onready var head = $Terrain/Props/KeeperHead

@export var boss_scene: PackedScene
var boss_instance: Node2D = null
var is_boss_alive:= true #add global for that
@onready var night_background: Node2D = $NightClouds
@onready var moon = $Enemy/moon
@onready var day_background = $DayBackground
@onready var trigger_area = $Cutscene/TriggerBoss
func _ready():
	
	if not is_boss_alive:
		head.visible = false

func first_phase_animation():
	var offsets = [Vector2(8,0), Vector2(-6,5), Vector2(4,-8), Vector2(-9,3), Vector2(5,-4), Vector2(-3,7), Vector2(7,-2), Vector2(-4,-5), Vector2(2,3)]
	for shake_index in 2:
		var shake_tween = create_tween()
		for offset in offsets:
			shake_tween.tween_property($Camera2D, "offset", offset, randf_range(0.05, 0.08)).set_trans(Tween.TRANS_SINE)
		shake_tween.tween_property($Camera2D, "offset", Vector2.ZERO, 0.15).set_trans(Tween.TRANS_SINE)
		await shake_tween.finished
		if shake_index == 0:
			await get_tree().create_timer(0.2).timeout
	var vanish_tween = create_tween()
	vanish_tween.tween_property(head, "scale", Vector2.ZERO, 1.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	var bg_tween = create_tween()
	bg_tween.tween_property(day_background, "modulate:a", 0.0, 2.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await get_tree().create_timer(0.8).timeout
	
	var moon_tween = create_tween()
	moon_tween.tween_property(moon, "modulate:a", 1.0, 3.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	var night_tween = create_tween()
	night_tween.tween_property(night_background, "modulate:a", 1.0, 3.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	await night_tween.finished
	
func second_phase_animation():
	var tween = create_tween()
	tween.tween_property($NightClouds/Parallax2D/background, "modulate", Color(1.8, 0.2, 0.2, 1.0), 3.0)
	await tween.finished
func on_boss_attack():
	var moon_tween = create_tween()
	moon_tween.tween_property(moon, "modulate", Color(1, 0, 0, 1), 1.0)
	moon_tween.tween_property(moon, "modulate", Color(1, 1, 1, 1), 1.0)

func on_boss_dead():
	var tween = create_tween()
	tween.parallel().tween_property(night_background, "modulate:a", 0.0, 2.0)
	tween.parallel().tween_property(day_background, "modulate:a", 1.0, 2.0)
	await tween.finished
func _on_trigger_boss_body_entered(body: Node2D):
	
	if body.is_in_group("player") and is_boss_alive:
		trigger_area.set_deferred("monitoring", false)
		trigger_area.set_deferred("monitorable", false)
		trigger_area.set_deferred("collision_layer", 0)
		trigger_area.set_deferred("collision_mask", 0)
		print("player entered, trigger boss")

		for door: DarkForestDoors in doors:
			door.close_door()
		await first_phase_animation()
		#do testowania		
		#await second_phase_animation()
		#
		#await on_boss_attack()
		
		
		if boss_instance != null:
			return

		boss_instance = boss_scene.instantiate()
		add_child(boss_instance)
		boss_instance.global_position = $BossSpawnerPosition.global_position
