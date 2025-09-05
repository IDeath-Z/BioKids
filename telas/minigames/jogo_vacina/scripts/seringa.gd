extends Area2D

@onready var braco = $braco

var segurando = false
var toque = Vector2.ZERO

func _ready():
	braco.visible = false

func _input(event):
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.pressed:
			segurando = true
			toque = global_position - event.position
			braco.visible = true
		else:
			segurando = false
			braco.visible = false

	elif event is InputEventMouseMotion or event is InputEventScreenDrag:
		if segurando:
			global_position = event.position + toque
