extends Node2D

enum Tipo {LARANJA = 0, VERDE = 1, VERMELHA = 2, ROXA = 3, VERDEG = 4}
var tipos_possiveis = ["laranja", "verde", "vermelha", "roxa", "maligna"]
var missao_atual: Tipo
var bacterias_restantes: int = 5  # Quantidade inicial por fase
var acertos: int = 0
var total_por_fase: int = 3  # Ex: 3 tipos por fase (pode ser removido se não for usado)
var fase: int = 0
var score: int = 0  # Nova variável para pontuação
var erros: int = 0  # Nova variável para contar erros

@onready var instrucao_label = $UI/InstrucaoLabel
@onready var mensagem_label = $UI/MensagemLabel
@onready var fato_label = $UI/FatoLabel
@onready var check_icon = $UI/CheckIcon
@onready var x_icon = $UI/XIcon
@onready var container = $BacteriaContainer
@onready var spawn_timer = $BacteriaSpawnTimer
@onready var vitoria_panel = $UI/VitoriaPanel  # Painel de vitória
@onready var game_over_panel = $UI/GameOverPanel  # Painel de Game Over
@onready var score_label = $UI/ScoreLabel  # Novo Label para exibir pontuação
@onready var jogar_novamente_button = $UI/JogarNovamente  # Referência ao botão existente
@onready var voltar_menu_button = $UI/VoltarMenu  # Referência ao botão existente
@onready var background = $Sprite2D
@onready var urso = $UI/Urso

var mensagens_certas = ["Boa! Você capturou uma bactéria certa!", "Ótimo trabalho!"]
var mensagens_erradas = ["Ops, essa não é a bactéria certa!", "Tente de novo!"]
var fatos = ["Tem bactérias boas que ajudam nosso corpo a ficar saudável, e tem bactérias ruins que podem deixar a gente doente. Por isso é importante lavar as mãos!"]
var screen_size

# Nova variável para controlar a velocidade base das bactérias
const BASE_SPEED = 100.0  # Velocidade base em pixels por segundo
var speed_increase_per_acert = 10.0  # Aumento de velocidade por acerto

func _ready():
	ajustar_tela()
	proxima_fase()
	spawn_timer.timeout.connect(on_bacteria_spawn_timeout)
	score_label.text = "Pontuação: " + str(score)  # Inicializa o Label
	game_over_panel.visible = false  # Garante que o painel de Game Over comece invisível


func _exit_tree():
	# Restaura o som do barramento Master ao sair da cena
	AudioServer.set_bus_mute(0, false)
	print("Música global restaurada via barramento Master ao sair")

func proxima_fase():
	fase += 1
	if fase > 3:
		completar_jogo()
		return
	acertos = 0
	bacterias_restantes = 5 + (fase * 2)  # Aumenta por fase
	erros = 0  # Reseta erros ao começar uma nova fase
	limpar_tela()
	missao_atual = Tipo.values()[randi() % Tipo.size()]
	instrucao_label.text = "Clique apenas nos germes " + tipos_possiveis[missao_atual] + "!"
	spawn_timer.wait_time = max(1.0, 3.0 - (fase * 0.5))  # Dificuldade: spawns mais rápidos
	spawn_timer.start()

func ajustar_tela():
	screen_size = get_viewport_rect().size
	background.size = Vector2(screen_size.x, screen_size.y)

func on_bacteria_spawn_timeout():
	if container.get_child_count() >= bacterias_restantes:
		return  # Limita quantidade
	var bact = preload("res://telas/minigames/caca_bacterias/scenes/Bacteria.tscn").instantiate()

	# Garante que screen_size seja calculado (caso ainda não tenha sido)
	if not screen_size:
		ajustar_tela()

	# Posicionamento dentro da área 720x1080 com margens maiores para evitar bordas
	var margem_x = 100  # Margem maior nas laterais
	var margem_y = 150  # Margem maior no topo/baixo
	var area_width = 720
	var area_height = 1080

	# Centraliza a área de spawn na viewport se ela for maior
	var offset_x = max(0, (screen_size.x - area_width) / 2)
	var offset_y = max(0, (screen_size.y - area_height) / 2)

	bact.position = Vector2(
		randf_range(offset_x + margem_x, offset_x + area_width - margem_x),
		randf_range(offset_y + margem_y, offset_y + area_height - margem_y)
	)

	# Define o tipo da bactéria com 50% de chance para o objetivo e 50% para outros
	var chance = randf()  # Gera um valor entre 0.0 e 1.0
	if chance < 0.5:  # 50% de chance de ser o tipo objetivo
		bact.tipo = missao_atual
	else:  # 50% de chance de ser outro tipo
		var outros_tipos = Tipo.values().filter(func(t): return t != missao_atual)
		bact.tipo = outros_tipos[randi() % outros_tipos.size()]

	var texturas = {
		Tipo.LARANJA: load("res://telas/minigames/caca_bacterias/assets/images/BacteriaLaranja.png"),
		Tipo.VERDE: load("res://telas/minigames/caca_bacterias/assets/images/Bacteriaverdemaligna.png"),
		Tipo.VERMELHA: load("res://telas/minigames/caca_bacterias/assets/images/Bacteriavermelha.png"),
		Tipo.ROXA: load("res://telas/minigames/caca_bacterias/assets/images/BacteriaROXA.png"),
		Tipo.VERDEG: load("res://telas/minigames/caca_bacterias/assets/images/BacteriaVERDE.png")
	}
	bact.get_node("SpriteBact").texture = texturas[bact.tipo]

	# Define a velocidade inicial com base nos acertos
	bact.speed = BASE_SPEED + (acertos * speed_increase_per_acert)

	# Adiciona um timer para remover a bactéria após 10 segundos se não for clicada
	var removal_timer = Timer.new()
	removal_timer.wait_time = 10.0  # 10 segundos
	removal_timer.one_shot = true  # Executa apenas uma vez
	removal_timer.timeout.connect(func():
		if is_instance_valid(bact):
			print("Removendo bactéria após 10s: ", bact)
			bact.queue_free()
	)
	if is_instance_valid(bact):
		bact.add_child(removal_timer)  # Adiciona o timer à árvore de cena primeiro
		removal_timer.start()  # Inicia o timer após adicionar
	else:
		print("Erro: Bactéria inválida ao criar timer!")

	container.add_child(bact)
	bact.clicada.connect(_on_bact_clicada.bind(bact))  # Passa a bactéria como bind

func _on_bact_clicada(tipo: Tipo, bact: Area2D):
	print("Sinal recebido. Tipo: ", tipo, " | Missão: ", missao_atual)
	# Remove todos os timers existentes antes de criar um novo
	for child in get_children():
		if child is Timer and child.is_connected("timeout", func(): mensagem_label.text = ""; check_icon.visible = false; x_icon.visible = false):
			print("Removendo timer existente: ", child)
			child.queue_free()

	if tipo == missao_atual:
		acertos += 1
		score += 10  # Adiciona 10 pontos por acerto
		score_label.text = "Pontuação: " + str(score)  # Atualiza o Label
		mensagem_label.text = mensagens_certas[randi() % mensagens_certas.size()]
		check_icon.visible = true
		x_icon.visible = false
		bact.queue_free()  # Remove a bactéria
	else:
		erros += 1  # Incrementa erros
		mensagem_label.text = mensagens_erradas[randi() % mensagens_erradas.size()]
		check_icon.visible = false
		x_icon.visible = true
		if erros >= 5:  # Condição de Game Over
			game_over()
			return
	var local_timer = Timer.new()
	add_child(local_timer)
	local_timer.timeout.connect(func():
		print("Timer de mensagem expirado")
		mensagem_label.text = ""; check_icon.visible = false; x_icon.visible = false
	)
	local_timer.wait_time = 1.5
	local_timer.start()
	# Removido o if acertos >= total_por_fase, pois não queremos finalizar por acertos

func limpar_tela():
	for child in container.get_children():
		child.queue_free()

func _on_jogar_novamente_pressed():
	fase = 0
	fato_label.text = ""
	jogar_novamente_button.visible = false
	voltar_menu_button.visible = false
	score = 0  # Reseta pontuação
	erros = 0  # Reseta erros
	score_label.text = "Pontuação: " + str(score)
	game_over_panel.visible = false  # Esconde o painel de Game Over

func _on_voltar_menu_pressed():
	# Transição direta para biofacts.tscn via conexão de sinal
	get_tree().change_scene_to_file("res://telas/minigames/caca_bacterias/scenes/biofacts.tscn")
	game_over_panel.visible = false  # Esconde o painel de Game Over

func completar_jogo():
	instrucao_label.text = "Parabéns! Você limpou o laboratório!"
	vitoria_panel.visible = true  # Mostra painel de vitória

func game_over():
	spawn_timer.stop()  # Para o spawn de bactérias
	limpar_tela()  # Remove todas as bactérias
	instrucao_label.text = "Game Over!"
	fato_label.text = "Você fez " + str(score) + " pontos!"
	urso.visible = false
	game_over_panel.visible = true  # Mostra o painel de Game Over
	jogar_novamente_button.visible = true
	voltar_menu_button.visible = true

func _on_botao_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/caca_bacterias/scenes/main_menu.tscn")
