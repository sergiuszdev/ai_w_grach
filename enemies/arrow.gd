extends Area2D

@export var speed := 400.0

var velocity := Vector2.ZERO

func _ready():
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	velocity.y += gravity*delta
	position += velocity*delta
	rotation = velocity.angle()


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.hit(5) # albo wywołaj metodę obrażeń
	queue_free()
