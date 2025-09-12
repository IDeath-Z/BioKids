extends Sprite2D

var tempo: float = 0.0
var amplitude: float = 8.0     # altura do movimento
var velocidade: float = 2.0    # rapidez da oscilação
var posicao_inicial: Vector2

var acumulador: float = 0.0
var intervalo: float = 0.5     # 0.5s por atualização → 2fps

func _ready():
	posicao_inicial = position

func _process(delta):
	acumulador += delta
	if acumulador >= intervalo:
		acumulador = 0.0
		tempo += intervalo * velocidade
		var deslocamento = sin(tempo) * amplitude
		position.y = posicao_inicial.y + int(deslocamento)
