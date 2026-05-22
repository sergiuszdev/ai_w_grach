extends Node2D

@onready var parallaxes = [$Parallax2D, $Parallax2D2, $Parallax2D3, $Parallax2D4]

func _process(delta):
	for parallax in parallaxes:
		parallax.scroll_offset.x += 8 * delta
		parallax.scroll_offset.y += 1 * delta
