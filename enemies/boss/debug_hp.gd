extends CanvasLayer

@onready var bar = $Control/ProgressBar

var boss: Node = null

func _ready():
	bar.visible = false

func set_boss(boss_instance):
	boss = boss_instance
	bar.visible = true

func _process(_delta):
	if boss == null:
		return

	if boss.has_method("get_health") and boss.has_method("get_max_health"):
		bar.max_value = boss.get_max_health()
		bar.value = boss.get_health()
