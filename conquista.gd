extends Node2D

@onready var anim = $capa

func _ready():
	anim.play("balanco") # troque pelo nome da animação configurada no SpriteFrames
