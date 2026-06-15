extends Area2D

@export var speed := 400.0
var direction := 1  # 1 = prawo, -1 = lewo

func _ready():
	scale.x = direction
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position.x += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.hit(5) # albo wywołaj metodę obrażeń
	queue_free()
