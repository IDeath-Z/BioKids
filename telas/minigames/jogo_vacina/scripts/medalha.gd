extends Sprite2D

var tempo: float = 0.0
var amplitude: float = 0.20
var velocidade: float = 0.9   
var escala_inicial: Vector2

func _ready():
	escala_inicial = scale

func _process(delta):
	tempo += delta * velocidade
	var fator = 1.0 + sin(tempo) * amplitude
	scale = escala_inicial * fator
