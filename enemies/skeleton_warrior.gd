extends GroundEnemy

@onready var sprite = $AnimatedSprite2D
@onready var animation_tree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]

enum State {
	IDLE,
	WALK,
	RUN,
	ATTACK,
	HURT,
	PROTECT,
	DEAD
}

var state: State = State.IDLE

var patrol_dir := 1
var patrol_timer := 0.0
var patrol_time := 2.0

var idle_timer := 0.0
var idle_time := 2.0

var walk_timer := 0.0
var walk_time := 2.5


func update_animation():
	match state:

		State.DEAD:
			playback.travel("dead")

		State.HURT:
			playback.travel("hurt")

		State.ATTACK:
			playback.travel("attack")

		State.PROTECT:
			playback.travel("protect")

		State.WALK:
			playback.travel("walk")

		State.IDLE:
			playback.travel("idle")

		State.RUN:
			playback.travel("run")


func ai_update(delta):

	if state in [State.ATTACK, State.HURT, State.PROTECT, State.DEAD]:
		velocity.x = 0
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

		if velocity.x != 0:
			sprite.flip_h = velocity.x < 0

		if walk_timer >= walk_time:
			walk_timer = 0.0
			state = State.IDLE
