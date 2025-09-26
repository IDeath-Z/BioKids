extends Area2D

@onready var macoste = $macoste
@onready var banqueta = $banqueta
@onready var colisao = $CollisionShape2D

signal conquista_feita 

func _ready():
	# Posição inicial fora da tela
	macoste.position = Vector2(371.2, -270.6)
	colisao.visible = false
	colisao.position = Vector2(306, 618)
	
	connect("area_entered", Callable(self, "_on_area_entered"))
	
	# Tween para macoste
	var tween1 = get_tree().create_tween()
	tween1.tween_property(macoste, "position", Vector2(345, 565), 1.8)
	
	await tween1.finished
	movimentar_local_vacina()
	
func movimentar_local_vacina():

	colisao.visible = true
	
	var locais = [
		Vector2(400, 618),
		Vector2(300, 650),
		Vector2(410, 660),
	]

	for pos in locais:
		var tween_move = get_tree().create_tween()
		tween_move.tween_property(colisao, "position", pos, 1.5)
		await tween_move.finished
	
func _on_area_entered(area):	
	if area.name == "seringa":
		emit_signal("conquista_feita")
