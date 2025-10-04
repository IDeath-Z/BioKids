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
@onready var music_player = $MusicPlayer if has_node("MusicPlayer") else null  # Verificação do nó
@onready var background = $Sprite2D
@onready var urso = $UI/Urso

var mensagens_certas = ["Boa! Você capturou uma bactéria certa!", "Ótimo trabalho!"]
var mensagens_erradas = ["Ops, essa não é a bactéria certa!", "Tente de novo!"]
var fatos = ["Tem bactérias boas que ajudam nosso corpo a ficar saudável, e tem bactérias ruins que podem deixar a gente doente. Por isso é importante lavar as mãos!"]
var screen_size

func _ready():
	ajustar_tela()
	proxima_fase()
	spawn_timer.timeout.connect(on_bacteria_spawn_timeout)
	score_label.text = "Pontuação: " + str(score)  # Inicializa o Label
	game_over_panel.visible = false  # Garante que o painel de Game Over comece invisível
	# Silencia a música global ao entrar na cena
	AudioServer.set_bus_mute(0, true)  # 0 é o barramento Master
	if music_player and music_player.stream:  # Verifica se o nó existe e tem stream
		music_player.play()  # Toca a música específica ao entrar na cena
	elif not music_player:
		print("Erro: Nó MusicPlayer não encontrado na cena!")

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
	instrucao_label.text = "Clique apenas nas bactérias " + tipos_possiveis[missao_atual] + "!"
	spawn_timer.wait_time = max(1.0, 3.0 - (fase * 0.5))  # Dificuldade: spawns mais rápidos
	spawn_timer.start()
	
func ajustar_tela():
	screen_size = get_viewport_rect().size
	background.size = Vector2(screen_size.x, screen_size.y)

func on_bacteria_spawn_timeout():
	if container.get_child_count() >= bacterias_restantes:
		return  # Limita quantidade
	var bact = preload("res://telas/minigames/caca_bacterias/scenes/Bacteria.tscn").instantiate()
	# Posicionamento relativo à viewport com margem
	var margem = 150  # Margem fixa em pixels, ajustável conforme necessário
	bact.position = Vector2(
		randf_range(margem, get_viewport_rect().size.x - margem),
		randf_range(margem, get_viewport_rect().size.y - margem)
	)
	# Define o tipo da bactéria com 40% de chance para o objetivo
	var chance = randf()  # Gera um valor entre 0.0 e 1.0
	if chance < 0.4:  # 40% de chance de ser o tipo objetivo
		bact.tipo = missao_atual
	else:  # 60% de chance de ser outro tipo
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
	container.add_child(bact)
	bact.clicada.connect(_on_bact_clicada.bind(bact))  # Passa a bactéria como bind

func _on_bact_clicada(tipo: Tipo, bact: Area2D):
	print("Sinal recebido. Tipo: ", tipo, " | Missão: ", missao_atual)
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
	local_timer.timeout.connect(func(): mensagem_label.text = ""; check_icon.visible = false; x_icon.visible = false)
	local_timer.start(2)
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
	if music_player and music_player.stream:
		music_player.stop()  # Para a música atual
		music_player.play()  # Reinicia a música ao reiniciar
	proxima_fase()

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
