extends Area2D

@onready var braco = $braco
@onready var seringa = $imagem_sering
var segurando = false
var toque = Vector2.ZERO

func _ready():
	braco.visible = false
	seringa.visible = false
	connect("area_entered", Callable(self, "_on_area_entered"))
	
func _input(event):
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.pressed:
			segurando = true
			toque = global_position - event.position
			braco.visible = true
			seringa.visible = true
		else:
			segurando = false
			braco.visible = false
			seringa.visible = false

	elif event is InputEventMouseMotion or event is InputEventScreenDrag:
		if segurando:
			global_position = event.position + toque


func _on_area_entered(area):
	if area.name == "local_vacina":
		get_tree().change_scene_to_file("res://telas/minigames/jogo_vacina/cenas/conquista.tscn")
