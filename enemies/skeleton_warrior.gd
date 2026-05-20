extends GroundEnemy

@onready var sprite = $AnimatedSprite2D
@onready var animation_tree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]
@onready var vision := $Vision

enum State { IDLE, WALK, RUN, ATTACK, HURT, PROTECT, DEAD }

var state: State = State.IDLE
var patrol_dir := 1
var idle_timer := 0.0
var idle_time := 2.0
var walk_timer := 0.0
var walk_time := 2.5
var target_player: Node2D = null

func update_animation():
	match state:
		State.DEAD:     playback.travel("dead")
		State.HURT:     playback.travel("hurt")
		State.ATTACK:   playback.travel("attack")
		State.PROTECT:  playback.travel("protect")
		State.WALK:     playback.travel("walk")
		State.IDLE:     playback.travel("idle")
		State.RUN:      playback.travel("run")

func ai_update(delta):
	if state in [State.ATTACK, State.HURT, State.PROTECT, State.DEAD]:
		velocity.x = 0
		return

	if target_player != null:
		state = State.RUN
		var dir = sign(target_player.global_position.x - global_position.x)
		velocity.x = dir * speed
		sprite.flip_h = velocity.x < 0
		vision.scale.x = -1 if sprite.flip_h else 1
		return

	if state == State.IDLE:
		velocity.x = 0
		idle_timer += delta
		if idle_timer >= idle_time:
			idle_timer = 0.0
			state = State.WALK
			if randf() < 0.5:
				patrol_dir *= -1

	elif state == State.WALK:
		walk_timer += delta
		velocity.x = patrol_dir * speed * 0.5
		sprite.flip_h = velocity.x < 0
		vision.scale.x = -1 if sprite.flip_h else 1
		if walk_timer >= walk_time:
			walk_timer = 0.0
			state = State.IDLE

func _on_vision_player_detected(body: Node2D):
	target_player = body

func _on_vision_player_lost():
	target_player = null
	state = State.IDLE
