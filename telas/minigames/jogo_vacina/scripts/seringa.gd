extends Area2D

var segurando = false
var toque = Vector2.ZERO
@onready var braco = $braco

func _ready():
	braco.visible = false	

func _input_event(viewport, event, shape_idx):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			segurando = true
			toque = global_position - event.position
			braco.visible = true 
		else:
			segurando = false
			braco.visible = false
	if event is InputEventScreenDrag:
		if segurando:
			global_position = event.position + toque
	if event is InputEventMouseMotion:
		if segurando:
			global_position = event.position + toque
