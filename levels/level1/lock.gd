extends Area2D

@onready var lock_sprite: AnimatedSprite2D = $".."
@onready var column_sprite: Sprite2D = $"../.."

var is_lock_opened = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_key == true:
			open_entrance(body)

func open_entrance(player: Node2D) -> void:
	is_lock_opened = true
	player.has_key = false
	
	lock_sprite.play("opening")
	
	await lock_sprite.animation_finished
	
	var tween = get_tree().create_tween()
	
	# Zabezpieczenie: jeśli z jakiegoś powodu tween dalej jest null, zatrzymaj funkcję
	if not tween:
		print("Błąd: Nie udało się stworzyć Tweena!")
		return
		
	# 2. Konfigurujemy styl przejścia (teraz na bezpiecznym tweenie)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# 3. Odpalamy ruch kolumny
	tween.tween_property(column_sprite, "position:y", column_sprite.position.y + 150, 1.5)
	
	# 4. Po skończeniu ruchu kasujemy całą kolumnę
	tween.tween_callback(column_sprite.queue_free)
	
	
