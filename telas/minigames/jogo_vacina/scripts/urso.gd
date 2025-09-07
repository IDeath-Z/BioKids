extends Node2D

@onready var macoste = $local_vacina/macoste
@onready var banqueta = $local_vacina/banqueta

func _ready():
	# Posição inicial fora da tela
	macoste.position = Vector2(990, 500)
	banqueta.position = Vector2(990, 600)

	# Tween para macoste
	var tween1 = get_tree().create_tween()
	tween1.tween_property(macoste, "position", Vector2(500, 550), 1.5)

	# Tween para banqueta
	var tween2 = get_tree().create_tween()
	tween2.tween_property(banqueta, "position", Vector2(510, 800), 1.5)
