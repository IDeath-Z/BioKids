extends Node2D

enum Tipo {LARANJA = 0, VERDE = 1, VERMELHA = 2, ROXA = 3, VERDEG = 4}
var tipos_possiveis = ["laranja", "verde", "vermelha", "roxa", "maligna"]
var missao_atual: Tipo
var bacterias_restantes: int = 5  # Quantidade inicial por fase
var acertos: int = 0
var total_por_fase: int = 3  # Ex: 3 tipos por fase
var fase: int = 0

@onready var instrucao_label = $UI/InstrucaoLabel
@onready var mensagem_label = $UI/MensagemLabel
@onready var fato_label = $UI/FatoLabel
@onready var check_icon = $UI/CheckIcon
@onready var x_icon = $UI/XIcon
@onready var container = $BacteriaContainer
@onready var spawn_timer = $BacteriaSpawnTimer  # Referência ao Timer

var mensagens_certas = ["Boa! Você capturou uma bactéria certa!", "Ótimo trabalho!"]
var mensagens_erradas = ["Ops, essa não é a bactéria certa!", "Tente de novo!"]
var fatos = ["Tem bactérias boas que ajudam nosso corpo a ficar saudável, e tem bactérias ruins que podem deixar a gente doente. Por isso é importante lavar as mãos!"]

func _ready():
	proxima_fase()
	spawn_timer.timeout.connect(on_bacteria_spawn_timeout)  # Conecta manualmente se não feito na cena

func proxima_fase():
	fase += 1
	if fase > 3:  # 3 fases progressivas
		completar_jogo()
		return
	acertos = 0
	limpar_tela()
	missao_atual = Tipo.values()[randi() % Tipo.size()]  # Aleatório
	instrucao_label.text = "Clique apenas nas bactérias " + tipos_possiveis[missao_atual] + "!"
	spawn_timer.start()  # Inicia o timer para gerar bactérias

func on_bacteria_spawn_timeout():
	var bact = preload("res://telas/minigames/caca_bacterias/scenes/Bacteria.tscn").instantiate()
	# Posição aleatória dentro de uma tela fixa de 720x1080 com margens maiores
	var screen_width = 720
	var screen_height = 1080
	var margem = 150  # Margem maior para evitar bordas
	bact.position = Vector2(
		randf_range(margem, screen_width - margem),
		randf_range(margem, screen_height - margem)
	)
	bact.tipo = Tipo.values()[randi() % Tipo.size()]
	var texturas = {
		Tipo.LARANJA: load("res://telas/minigames/caca_bacterias/assets/images/BacteriaLaranja.png"),
		Tipo.VERDE: load("res://telas/minigames/caca_bacterias/assets/images/Bacteriaverdemaligna.png"),
		Tipo.VERMELHA: load("res://telas/minigames/caca_bacterias/assets/images/Bacteriavermelha.png"),
		Tipo.ROXA: load("res://telas/minigames/caca_bacterias/assets/images/BacteriaROXA.png"),
		Tipo.VERDEG: load("res://telas/minigames/caca_bacterias/assets/images/BacteriaVERDE.png")
	}
	bact.get_node("SpriteBact").texture = texturas[bact.tipo]
	container.add_child(bact)
	var error = bact.clicada.connect(_on_bact_clicada)
	if error == OK:
		print("Sinal 'clicada' conectado com sucesso para bactéria em: ", bact.position)
	else:
		print("Erro ao conectar sinal 'clicada': ", error)

func _on_bact_clicada(tipo: Tipo):
	print("Sinal recebido. Tipo: ", tipo, " | Missão: ", missao_atual)  # Depuração
	if tipo == missao_atual:
		acertos += 1
		mensagem_label.text = mensagens_certas[randi() % mensagens_certas.size()]
		check_icon.visible = true
		x_icon.visible = false
	else:
		mensagem_label.text = mensagens_erradas[randi() % mensagens_erradas.size()]
		check_icon.visible = false
		x_icon.visible = true
	var local_timer = Timer.new()
	add_child(local_timer)
	local_timer.timeout.connect(func(): mensagem_label.text = ""; check_icon.visible = false; x_icon.visible = false)
	local_timer.start(2)
	if acertos >= total_por_fase:
		await get_tree().create_timer(2).timeout
		fato_label.text = fatos[randi() % fatos.size()]
		$UI/JogarNovamente.visible = true
		$UI/VoltarMenu.visible = true
		spawn_timer.stop()  # Para o timer ao completar a fase

func limpar_tela():
	for child in container.get_children():
		child.queue_free()

func _on_jogar_novamente_pressed():
	fase = 0
	fato_label.text = ""
	$UI/JogarNovamente.visible = false
	$UI/VoltarMenu.visible = false
	proxima_fase()

func _on_voltar_menu_pressed():
	get_tree().change_scene_to_file("res://telas/minigames/caca_bacterias/scenes/main_menu.tscn")

func completar_jogo():
	instrucao_label.text = "Parabéns! Você limpou o laboratório!"
