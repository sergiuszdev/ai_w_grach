extends Node2D

# Jeśli silnik dalej zgłasza null, spróbuj zapisać to w _ready() zamiast @onready
var parallaxes = []

func _ready():
	# Bezpieczniejsze przypisanie – upewnij się, że nazwy pasują do Twojego drzewa!
	parallaxes = [$Parallax2D, $Parallax2D2, $Parallax2D3, $Parallax2D4]

func _process(delta):
	for parallax in parallaxes:
		if parallax: # Sprawdza, czy obiekt na pewno istnieje (nie jest nullem)
			# W Godot 4 używamy screen_offset zamiast scroll_offset
			parallax.screen_offset.x += 8 * delta
			parallax.screen_offset.y += 1 * delta
