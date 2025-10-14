extends Area2D

signal clicada(tipo: Tipo)

enum Tipo {LARANJA = 0, VERDE = 1, VERMELHA = 2, ROXA = 3, VERDEG = 4}
var tipo: Tipo
var velocidade: Vector2 = Vector2.ZERO
var tempo_flutuacao: float = 0.0
var tempo_multiplicacao: float = 0.0
var intervalo_multiplicacao: float
var speed: float = 100.0  # Mantém a variável de velocidade

func _ready():
	# Inicializa a direção aleatória baseada na speed
	velocidade = Vector2(randf_range(-speed, speed), randf_range(-20, 20)).normalized() * speed
	input_event.connect(_on_input_event)
	intervalo_multiplicacao = randf_range(5.0, 12.0)
	print("Bactéria pronta. Tipo: ", tipo)

func _process(delta):
	tempo_flutuacao += delta
	tempo_multiplicacao += delta

	# Move a bactéria usando a velocidade
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
		if get_parent().get_child_count() < 10:  # Limite de 10 bactérias
			_on_multiply()
		tempo_multiplicacao = 0.0

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if tipo != null:
			print("Clique detectado. Tipo: ", tipo)
			# Emite o sinal imediatamente
			clicada.emit(tipo)
			# Toca a animação em segundo plano, sem esperar
			var anim = $AnimationPlayer
			if anim and is_instance_valid(anim):
				anim.play("fade_out")
			queue_free()  # Remove a bactéria imediatamente
		else:
			print("Erro: Tipo não definido!")

func _on_multiply():
	var nova_bact = preload("res://telas/minigames/caca_bacterias/scenes/Bacteria.tscn").instantiate()
	nova_bact.tipo = tipo
	nova_bact.position = position + Vector2(randf_range(-30, 30), randf_range(-30, 30))
	nova_bact.speed = speed  # Passa a velocidade atual para a nova bactéria
	var texturas = {
		Tipo.LARANJA: load("res://telas/minigames/caca_bacterias/assets/images/BacteriaLaranja.png"),
		Tipo.VERDE: load("res://telas/minigames/caca_bacterias/assets/images/Bacteriaverdemaligna.png"),
		Tipo.VERMELHA: load("res://telas/minigames/caca_bacterias/assets/images/Bacteriavermelha.png"),
		Tipo.ROXA: load("res://telas/minigames/caca_bacterias/assets/images/BacteriaROXA.png"),
		Tipo.VERDEG: load("res://telas/minigames/caca_bacterias/assets/images/BacteriaVERDE.png")
	}
	var sprite = nova_bact.get_node_or_null("SpriteBact")
	if sprite:
		sprite.texture = texturas[nova_bact.tipo]
		print("Textura aplicada a nova bactéria. Tipo: ", nova_bact.tipo)
	else:
		print("Erro: Nó SpriteBact não encontrado na nova bactéria!")
	get_parent().add_child(nova_bact)
	var error = nova_bact.clicada.connect(func(t): get_parent().get_parent()._on_bact_clicada(t, nova_bact))
	if error == OK:
		print("Sinal conectado na nova bactéria.")
	else:
		print("Erro ao conectar sinal na nova bactéria: ", error)
