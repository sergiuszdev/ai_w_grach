extends CanvasLayer

@onready var bar = $Control/ProgressBar

func _ready():
	bar.max_value = Globals.max_players_health
	bar.value = Globals.players_health

func _process(_delta):
	bar.value = Globals.players_health
