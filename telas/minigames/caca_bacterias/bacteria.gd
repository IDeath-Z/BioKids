extends Area2D
signal clicada(tipo: Tipo)

enum Tipo {AZUL = 0, VERDE = 1, VERMELHA = 2, ROSA = 3, VERDEMALIGNA = 4}
var tipo: Tipo
var velocidade: Vector2 = Vector2.ZERO
var tempo_flutuacao: float = 0.0
var tempo_multiplicacao: float = 0.0
var intervalo_multiplicacao: float

func _ready():
	velocidade = Vector2(randf_range(-30, 30), randf_range(-20, 20))
	input_event.connect(_on_input_event)
	intervalo_multiplicacao = randf_range(5.0, 12.0)

func _process(delta):
	tempo_flutuacao += delta
	tempo_multiplicacao += delta

	position += velocidade * delta
	position.y += sin(tempo_flutuacao * 2.0) * 20 * delta

	var viewport_size = get_viewport_rect().size
	var raio = 50

	if position.x - raio < 0:
		position.x = raio
		velocidade.x = abs(velocidade.x)
	elif position.x + raio > viewport_size.x:
		position.x = viewport_size.x - raio
		velocidade.x = -abs(velocidade.x)

	if position.y - raio < 0:
		position.y = raio
		velocidade.y = abs(velocidade.y)
	elif position.y + raio > viewport_size.y:
		position.y = viewport_size.y - raio
		velocidade.y = -abs(velocidade.y)

	if tempo_multiplicacao >= intervalo_multiplicacao and not is_queued_for_deletion():
		_on_multiply()
		tempo_multiplicacao = 0.0

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		clicada.emit(tipo)
		queue_free()

func _on_multiply():
	var nova_bact = preload("res://scenes/Bacteria.tscn").instantiate()
	nova_bact.tipo = tipo
	nova_bact.position = position + Vector2(randf_range(-30, 30), randf_range(-30, 30))
	var texturas = {
		Tipo.AZUL: load("res://assets/images/BacteriaAZULFELIZ.png"),
		Tipo.VERDE: load("res://assets/images/Bacteriaverdemaligna.png"),
		Tipo.VERMELHA: load("res://assets/images/Bactéria vermelha.png"),
		Tipo.ROSA: load("res://assets/images/BacteriaROSA.png"),
		Tipo.VERDEMALIGNA: load("res://assets/images/BacteriaVERDEESCURO.png")
	}
	if nova_bact.get_node_or_null("SpriteBact"):  # Verifica se o nó existe
		nova_bact.get_node("SpriteBact").texture = texturas[nova_bact.tipo]
	get_parent().add_child(nova_bact)
	nova_bact.clicada.connect(func(t): get_parent().get_parent()._on_bact_clicada(t))
