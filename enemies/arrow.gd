extends Area2D

@export var speed := 400.0
var direction := 1  # 1 = prawo, -1 = lewo
var velocity_y := 0.0

func _ready():
	scale.x = direction
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	velocity_y += gravity * delta / 30
	position.x += direction * speed * delta
	position.y += velocity_y*delta 
	
	rotation = atan2(velocity_y, direction * speed)


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.hit(5) # albo wywołaj metodę obrażeń
	queue_free()
