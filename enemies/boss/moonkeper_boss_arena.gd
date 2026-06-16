extends Node2D

@onready var doors = [$Terrain/Props/RightDoor, $Terrain/Props/LeftDoor]
@onready var head = $Enemy/KeeperHead
@export var boss_scene: PackedScene
var boss_instance: Node2D = null
var is_boss_alive := Globals.is_moonkeeper_alive
@onready var doors_closed := false

@onready var debug_hp = $DebugHp
@onready var night_background = $NightClouds
@onready var day_background = $DayBackground
@onready var trigger_area = $Cutscene/TriggerBoss
@onready var moon = $Enemy/moon
@onready var upper_bound = $ArenaConstraints/Up

@onready var player = $Player

var phase2_active = false
var action_memory := {}


enum Phase {
	NO_PHASE,
	PHASE_1,
	PHASE_2,
	PHASE_3
}

@export var current_phase: Phase = Phase.NO_PHASE

func _ready():
	player.player_action.connect(_on_player_action)
	action_memory = {
		"ATTACK": 0,
		"UP_ATTACK": 0,
		"DOWN_ATTACK": 0,
		"SLIDE": 0,
		"JUMP": 0,
		"WALL_JUMP": 0,
		"PARRY": 0,
		"HEAL": 0,
		"HIT": 0
	}
	
	
	match current_phase:
		Phase.NO_PHASE:
			print("no phase")

		Phase.PHASE_1:
			start_phase_one()

		Phase.PHASE_2:
			start_phase_two()
			

		Phase.PHASE_3:
			start_phase_three()
			
	if not is_boss_alive:
		head.visible = false

func _process(_delta):
	decay_player_memory()
	
	if boss_instance and is_boss_alive:
		if boss_instance.current_hp <= 0:
			is_boss_alive = false
			Globals.is_moonkeeper_alive = false

			boss_instance.die()
			await on_defeat()

func on_defeat():
	doors_closed = false

	for door in doors:
		door.open_door()

	if boss_instance:
		boss_instance.die()

		await get_tree().create_timer(2.0).timeout

		boss_instance.queue_free()
		boss_instance = null

	head.visible = false
	moon.visible = false

	await on_boss_dead()

	PlayerStats.max_jumps = 2
	Globals.is_moonkeeper_alive = false
	
func start_phase_three():
	current_phase = Phase.PHASE_3
	if boss_instance:
		boss_instance.blackboard.set_value("phase", Phase.PHASE_3)
		boss_instance.blackboard.set_value("got_hit", false)
		boss_instance.blackboard.set_value("moon", moon)
		boss_instance.velocity = Vector2.ZERO
		boss_instance.attack_ended()
		boss_instance.state = boss_instance.States.IDLE
		boss_instance.playback.travel("idle")
	third_phase_animation()
	
func start_phase_two():
	
	phase2_active = true
	$Timers/Phase2Timer.start()

	
	await second_phase_animation()
	
	upper_bound.disabled = false
	moon.enter_hostile_mode()

func first_phase_animation():

	var offsets = [
		Vector2(8,0),
		Vector2(-6,5),
		Vector2(4,-8),
		Vector2(-9,3),
		Vector2(5,-4),
		Vector2(-3,7),
		Vector2(7,-2),
		Vector2(-4,-5),
		Vector2(2,3)
	]

	for shake_index in 2:

		var shake_tween = create_tween()

		for offset in offsets:
			shake_tween.tween_property(
				$Camera2D,
				"offset",
				offset,
				randf_range(0.05, 0.08)
			).set_trans(Tween.TRANS_SINE)

		shake_tween.tween_property(
			$Camera2D,
			"offset",
			Vector2.ZERO,
			0.15
		).set_trans(Tween.TRANS_SINE)

		await shake_tween.finished

		if shake_index == 0:
			await get_tree().create_timer(0.2).timeout

	var vanish_tween = create_tween()

	vanish_tween.tween_property(
		head,
		"scale",
		Vector2.ZERO,
		1.0
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)

	var bg_tween = create_tween()

	bg_tween.tween_property(
		day_background,
		"modulate:a",
		0.0,
		2.5
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

	await get_tree().create_timer(0.8).timeout

	moon.appear()

	var night_tween = create_tween()

	night_tween.tween_property(
		night_background,
		"modulate:a",
		1.0,
		3.0
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

	await night_tween.finished

func second_phase_animation():

	if boss_instance == null:
		return

	boss_instance.visible = true

	var spawn_pos = $BossSpawnerPosition.global_position
	var start_pos = boss_instance.global_position

	var boss_tween = create_tween()

	boss_tween.set_trans(Tween.TRANS_SINE)
	boss_tween.set_ease(Tween.EASE_IN_OUT)

	var mid_pos = (start_pos + spawn_pos) * 0.5
	mid_pos.y -= 160
	
	
	var moon_tween = create_tween()

	moon_tween.tween_property(
		moon,
		"scale",
		Vector2(2.5, 2.5),
		2.0
	)
	
	moon_tween.parallel().tween_property(
		moon,
		"global_position",
		$Enemy/SecondPhaseMoon.global_position,
		2.0
	)

	boss_tween.parallel().tween_property(
		boss_instance,
		"global_position",
		mid_pos,
		0.4
	)

	boss_tween.parallel().tween_property(
		boss_instance,
		"global_position",
		spawn_pos,
		0.6
	)
	await boss_tween.finished
	pause_boss()
	var tween = create_tween()

	tween.parallel().tween_property(
		head,
		"modulate:a",
		1.0,
		2.0
	)

	tween.parallel().tween_property(
		head,
		"scale",
		Vector2(6.0, 6.0),
		2.0
	)

	tween.parallel().tween_property(
		night_background,
		"modulate",
		Color(1.0, 1.0, 1.0, 1.0),
		2.5
	)

	await tween.finished

func third_phase_animation():
	boss_instance.z_index = 150
	upper_bound.disabled = true
	moon.normal()
	var moon_tween = create_tween()
	moon_tween.tween_property(
		moon,
		"scale",
		Vector2(5.0, 5.0),
		2.0
	)
	
	moon_tween.parallel().tween_property(
		moon,
		"global_position",
		$Enemy/SecondPhaseMoon.global_position,
		2.0
	)
	
	head.scale = Vector2(6.0, 6.0)

	var offsets = [
		Vector2(8,0),
		Vector2(-6,5),
		Vector2(4,-8),
		Vector2(-9,3),
		Vector2(5,-4),
		Vector2(-3,7),
		Vector2(7,-2),
		Vector2(-4,-5),
		Vector2(2,3)
	]

	for shake_index in 2:

		var shake_tween = create_tween()

		for offset in offsets:
			shake_tween.tween_property(
				$Camera2D,
				"offset",
				offset,
				randf_range(0.05, 0.08)
			)

		shake_tween.tween_property(
			$Camera2D,
			"offset",
			Vector2.ZERO,
			0.15
		)

		await shake_tween.finished

	var tween = create_tween()

	tween.parallel().tween_property(
		head,
		"modulate:a",
		1.0,
		0.5
	)

	tween.parallel().tween_property(
		head,
		"scale",
		Vector2.ZERO,
		1.0
	)

	tween.parallel().tween_property(
		$NightClouds,
		"modulate",
		Color(1.8, 0.2, 0.2, 1.0),
		3.0
	)

	await tween.finished

	resume_boss()


func on_boss_dead():

	var tween = create_tween()

	tween.parallel().tween_property(
		night_background,
		"modulate:a",
		0.0,
		2.0
	)

	tween.parallel().tween_property(
		day_background,
		"modulate:a",
		1.0,
		2.0
	)

	await tween.finished

func start_phase_one():
	current_phase = Phase.PHASE_1
	trigger_area.set_deferred("monitoring", false)
	trigger_area.set_deferred("monitorable", false)
	trigger_area.set_deferred("collision_layer", 0)
	trigger_area.set_deferred("collision_mask", 0)
	
	for door in doors:
		door.close_door()
		doors_closed = true

	await first_phase_animation()

	if boss_instance != null:
		return

	boss_instance = boss_scene.instantiate()
	add_child(boss_instance)
	boss_instance.blackboard.set_value("phase", current_phase)
	boss_instance.global_position = $BossSpawnerPosition.global_position
	boss_instance.moon = moon

	boss_instance.health_changed.connect(_on_boss_health_changed)

	debug_hp.set_boss(boss_instance)
	
	trigger_area.set_deferred("monitoring", false)
	trigger_area.set_deferred("monitorable", false)
	trigger_area.set_deferred("collision_layer", 0)
	trigger_area.set_deferred("collision_mask", 0)

func _on_trigger_boss_body_entered(body: Node2D):
	if not body.is_in_group("player") or not is_boss_alive or not current_phase == Phase.NO_PHASE:
		return
	start_phase_one()


func pause_boss():

	if boss_instance == null:
		return
	boss_instance.blackboard.set_value("boss_paused", true)
	boss_instance.velocity = Vector2.ZERO
	boss_instance.set_physics_process(false)

func resume_boss():
	

	if boss_instance == null:
		return
		
	boss_instance.blackboard.set_value("boss_paused", false)
	boss_instance.blackboard.set_value("got_hit", false)
	boss_instance.velocity = Vector2.ZERO
	boss_instance.attack_ended()
	boss_instance.state = boss_instance.States.IDLE
	boss_instance.set_physics_process(true)
	
func _on_boss_health_changed(hp, max_hp):
	var pct = float(hp) / float(max_hp) * 100.0

	if pct < 70 and current_phase == Phase.PHASE_1:
		_switch_phase(Phase.PHASE_2)


func _on_phase_2_timer_timeout():
	_switch_phase(Phase.PHASE_3)
	


func _switch_phase(p):
	current_phase = p

	if boss_instance:
		boss_instance.blackboard.set_value("phase", p)

	match p:
		Phase.PHASE_2:
			start_phase_two()
		Phase.PHASE_3:
			start_phase_three()
			
func _on_player_action(action: String, _context: Dictionary):
	if not action_memory.has(action):
		action_memory[action] = 0

	action_memory[action] += 1
	if boss_instance:
		boss_instance.blackboard.set_value("player_action_memory", action_memory)
func decay_player_memory():
	for key in action_memory.keys():
		action_memory[key] = max(0, action_memory[key] - 0.05)


func _on_go_to_road_body_entered(body):
	if not doors_closed:
		if body.is_in_group("player"):
			Globals.goto_scene("uid://eyghx6bknct")
