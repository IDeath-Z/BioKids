extends Area2D

@onready var macoste = $macoste
@onready var banqueta = $banqueta
@onready var colisao = $CollisionShape2D

signal conquista_feita 

var colision_mover := false

func _ready():
	# Posição inicial fora da tela
	macoste.position = Vector2(371.2, -270.6)
	colisao.visible = false
	colisao.position = Vector2(306, 618)
	
	connect("area_entered", Callable(self, "_on_area_entered"))
	
	# Tween para macoste
	var tween1 = get_tree().create_tween()
	tween1.tween_property(macoste, "position", Vector2(350, 590), 1.8)
	
	await tween1.finished
	colision_mover = true   


func _input(event):
	if colision_mover and event is InputEventMouseButton and event.pressed:
		colision_mover = false
		movimentar_local_vacina()


func movimentar_local_vacina():
	colisao.visible = true
	
	var locais = [
		Vector2(415, 618),
		Vector2(300, 650),
		Vector2(410, 660),
		Vector2(285, 680),
		Vector2(430, 680),
	]

	var pausa := 0.09
	while true:
		# ida
		for pos in locais:
			var tween_move = get_tree().create_tween()
			tween_move.tween_property(colisao, "position", pos, 1.0)
			await tween_move.finished
			await get_tree().create_timer(pausa).timeout

		# volta
		var idx := locais.size() - 2
		while idx >= 0:
			var pos = locais[idx]
			var tween_move = get_tree().create_tween()
			tween_move.tween_property(colisao, "position", pos, 1.0)
			await tween_move.finished
			await get_tree().create_timer(pausa).timeout
			idx -= 1
	

func _on_area_entered(area):	
	if area.name == "seringa":
		emit_signal("conquista_feita")
