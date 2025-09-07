extends Area2D

@onready var macoste = $macoste
@onready var banqueta = $banqueta
@onready var colisao = $CollisionShape2D

signal conquista_feita 

func _ready():
	# Posição inicial fora da tela
	macoste.position = Vector2(990, 500)
	banqueta.position = Vector2(990, 600)
	colisao.position = Vector2(990, 500)

	# Tween para macoste
	var tween1 = get_tree().create_tween()
	tween1.tween_property(macoste, "position", Vector2(500, 550), 1.5)

	# Tween para banqueta
	var tween2 = get_tree().create_tween()
	tween2.tween_property(banqueta, "position", Vector2(510, 800), 1.5)
	
	var tween3 = get_tree().create_tween()
	tween2.tween_property(colisao, "position", Vector2(455, 620), 1.5)
	
	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area):	
	if area.name == "seringa":
		emit_signal("conquista_feita")
