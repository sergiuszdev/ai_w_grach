extends CanvasLayer

@onready var bar := $Control/VBoxContainer/PlayerHealth
@onready var money := $Control/VBoxContainer/money/value
func _ready():
	bar.max_value = PlayerStats.max_players_health
	bar.value = PlayerStats.players_health
	
	money.text = str(PlayerStats.money)

func _process(_delta):
	bar.value = PlayerStats.players_health
	money.text = str(PlayerStats.money)
