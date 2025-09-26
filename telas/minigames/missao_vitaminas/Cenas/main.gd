extends Node2D

var countdown = 3
var game_started = false
var current_saudavel_index: int = 0
var current_nao_saudavel_index: int = 0
var prev_saudavel_index: int = -1
var prev_nao_saudavel_index: int = -1

# Variáveis @onready para inicialização segura
@onready var max_saudaveis: int = load("res://Cenas/comida_saudavel.tscn").instantiate().sprites_saudaveis.size() if ResourceLoader.exists("res://Cenas/comida_saudavel.tscn") else 0
@onready var max_nao_saudaveis: int = load("res://Cenas/comida_nao_saudavel.tscn").instantiate().sprites_nao_saudaveis.size() if ResourceLoader.exists("res://Cenas/comida_nao_saudavel.tscn") else 0
@onready var background_music = $UILayer/BackgroundMusic if has_node("UILayer/BackgroundMusic") else null
@onready var left_button = $UILayer/TouchControls/LeftButton if has_node("UILayer/TouchControls/LeftButton") else null
@onready var right_button = $UILayer/TouchControls/RightButton if has_node("UILayer/TouchControls/RightButton") else null

# Variáveis para controlar a velocidade de queda dos alimentos
var base_fall_speed: float = 200.0
var fall_speed_increment: float = 50.0
var max_fall_speed: float = 1000.0
var current_fall_speed: float = base_fall_speed

# Variáveis para controlar a velocidade do player
var base_player_speed: float = 240.0
var player_speed_increment: float = 20.0
var max_player_speed: float = 400.0
var current_player_speed: float = base_player_speed

# Variáveis para controlar o intervalo de spawn
var base_spawn_wait: float = 1.0
var min_spawn_wait: float = 0.3
var current_spawn_wait: float = base_spawn_wait

func _ready():
	# Seleciona o par inicial aleatoriamente
	if max_saudaveis > 0 and max_nao_saudaveis > 0:
		change_food_pair()
	else:
		print("Erro: Cenas de comida não carregadas ou sem sprites!")

	# Inicia a música de fundo
	if background_music:
		background_music.volume_db = -10.0
		background_music.play()
		background_music.finished.connect(func(): background_music.play())
		print("Música de fundo iniciada com volume -10.0 dB")
	else:
		print("Erro: BackgroundMusic não encontrado!")

	# Conecta os sinais dos botões
	var start_button = $MenuLayer/StartButton if $MenuLayer and $MenuLayer.has_node("StartButton") else null
	if start_button:
		start_button.pressed.connect(_on_start_button_pressed)
		start_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS  # Corrige bug no Android
		start_button.focus_mode = Control.FOCUS_ALL
		start_button.mouse_filter = Control.MOUSE_FILTER_STOP
		start_button.disabled = false
		print("StartButton configurado para mobile")
	else:
		print("Erro: StartButton não encontrado!")

	var info_button = $MenuLayer/InfoButton if $MenuLayer and $MenuLayer.has_node("InfoButton") else null
	if info_button:
		info_button.pressed.connect(_on_info_button_pressed)
		info_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS  # Corrige bug no Android
		info_button.focus_mode = Control.FOCUS_ALL
		info_button.mouse_filter = Control.MOUSE_FILTER_STOP
		info_button.disabled = false
		print("InfoButton configurado para mobile")
	else:
		print("Erro: InfoButton não encontrado!")

	# Conecta o botão de menu
	var menu_button = $UILayer/MenuButton if $UILayer and $UILayer.has_node("MenuButton") else null
	if menu_button:
		if menu_button.pressed.is_connected(_on_menu_button_pressed):
			menu_button.pressed.disconnect(_on_menu_button_pressed)
		menu_button.pressed.connect(_on_menu_button_pressed)
		menu_button.visible = false
		menu_button.disabled = false
		print("MenuButton conectado: visível = ", menu_button.visible, ", disabled = ", menu_button.disabled)
	else:
		print("Erro: MenuButton não encontrado!")

	# Configura o SpawnTimer
	var spawn_timer = $SpawnerComida/SpawnTimer if $SpawnerComida and $SpawnerComida.has_node("SpawnTimer") else null
	if spawn_timer:
		spawn_timer.wait_time = current_spawn_wait
		spawn_timer.paused = true
		if spawn_timer.is_stopped():
			spawn_timer.start()
	else:
		print("Erro: SpawnTimer não encontrado!")

	# Pausa o movimento do Player
	if has_node("Player"):
		$Player.set_process(false)
	else:
		print("Erro: Player não encontrado!")

	# Define a visibilidade dos fundos
	if $BackgroundBlurred:
		$BackgroundBlurred.visible = true
	else:
		print("Erro: BackgroundBlurred não encontrado!")
	if $BackgroundNormal:
		$BackgroundNormal.visible = false
	else:
		print("Erro: BackgroundNormal não encontrado!")

	# Inicializa o PontosLabel
	var pontos_label = $UILayer/PontosLabel if $UILayer and $UILayer.has_node("PontosLabel") else null
	if pontos_label:
		pontos_label.text = "Pontos: 0"
	else:
		print("Erro: PontosLabel não encontrado!")

	# Esconde o CountdownLabel
	var countdown_label = $UILayer/CountdownLabel if $UILayer and $UILayer.has_node("CountdownLabel") else null
	if countdown_label:
		countdown_label.visible = false
	else:
		print("Erro: CountdownLabel não encontrado!")

	# Esconde o GameOverLabel e FinalScoreLabel
	var game_over_label = $UILayer/GameOverLabel if $UILayer and $UILayer.has_node("GameOverLabel") else null
	if game_over_label:
		game_over_label.visible = false
	else:
		print("Erro: GameOverLabel não encontrado!")

	var final_score_label = $UILayer/FinalScoreLabel if $UILayer and $UILayer.has_node("FinalScoreLabel") else null
	if final_score_label:
		final_score_label.visible = false
		final_score_label.autowrap_mode = TextServer.AUTOWRAP_OFF
		final_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		final_score_label.text = "Pontos: 0"
		await get_tree().process_frame
		var text_rect = final_score_label.get_rect()
		final_score_label.size = text_rect.size
		final_score_label.text = ""
		print("FinalScoreLabel inicializado, tamanho: ", text_rect.size)
	else:
		print("Erro: FinalScoreLabel não encontrado!")

	# Verifica sons
	if $UILayer/CountdownTickSound:
		print("CountdownTickSound encontrado")
	else:
		print("Erro: CountdownTickSound não encontrado!")
	if $UILayer/StartRaceSound:
		print("StartRaceSound encontrado")
	else:
		print("Erro: StartRaceSound não encontrado!")

	# Centraliza botões
	center_buttons()

	# Configura botões de toque
	if left_button and right_button:
		left_button.visible = false
		right_button.visible = false
		left_button.position = Vector2(90, 820)
		right_button.position = Vector2(510, 820)
		print("Botões touch configurados")
	else:
		print("Erro: Botões touch não encontrados!")

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var menu_button = $UILayer/MenuButton
		if menu_button and menu_button.visible and menu_button.get_global_rect().has_point(event.global_position):
			print("Clique direto detectado no MenuButton!")
			_on_menu_button_pressed()

func increase_fall_speed() -> void:
	current_fall_speed = min(current_fall_speed + fall_speed_increment, max_fall_speed)
	print("Velocidade de queda aumentada para: ", current_fall_speed)

func increase_player_speed() -> void:
	current_player_speed = min(current_player_speed + player_speed_increment, max_player_speed)
	if has_node("Player"):
		$Player.velocidade = current_player_speed
	print("Velocidade do player aumentada para: ", current_player_speed)

func decrease_spawn_wait() -> void:
	if current_fall_speed >= max_fall_speed:
		current_spawn_wait = min_spawn_wait
	else:
		var progress = (current_fall_speed - base_fall_speed) / (max_fall_speed - base_fall_speed)
		var k = log(base_spawn_wait / min_spawn_wait) * 1.2
		current_spawn_wait = base_spawn_wait * exp(-progress * k)
	
	var spawn_timer = $SpawnerComida/SpawnTimer if $SpawnerComida and $SpawnerComida.has_node("SpawnTimer") else null
	if spawn_timer:
		spawn_timer.wait_time = current_spawn_wait
	print("Intervalo de spawn ajustado para: ", current_spawn_wait)

func _on_start_button_pressed():
	if $MenuLayer:
		$MenuLayer.visible = false
	start_countdown()

func start_countdown() -> void:
	var countdown_label = $UILayer/CountdownLabel if $UILayer and $UILayer.has_node("CountdownLabel") else null
	if not countdown_label:
		print("Erro: CountdownLabel não encontrado!")
		return
	
	if background_music:
		background_music.volume_db = -20.0
		print("Volume da música reduzido para -20.0 dB")
	
	var viewport_size = get_viewport_rect().size
	countdown_label.position = Vector2(viewport_size.x / 2 - countdown_label.size.x / 2, viewport_size.y / 2)
	countdown_label.visible = true
	
	while countdown > 0:
		countdown_label.text = str(countdown)
		if $UILayer/CountdownTickSound:
			$UILayer/CountdownTickSound.play()
		await get_tree().create_timer(1.0).timeout
		countdown -= 1
	
	countdown_label.text = "VAI!"
	if $UILayer/StartRaceSound:
		$UILayer/StartRaceSound.play()
	await get_tree().create_timer(1.0).timeout
	
	if background_music:
		background_music.volume_db = -10.0
		print("Volume da música restaurado para -10.0 dB")
	
	countdown_label.visible = false
	game_started = true
	if $BackgroundBlurred:
		$BackgroundBlurred.visible = false
	if $BackgroundNormal:
		$BackgroundNormal.visible = true
	if has_node("Player"):
		$Player.set_process(true)
	if $SpawnerComida and $SpawnerComida.has_node("SpawnTimer"):
		if $SpawnerComida/SpawnTimer.is_stopped():
			$SpawnerComida/SpawnTimer.start()
		$SpawnerComida/SpawnTimer.paused = false
	
	if left_button and right_button:
		left_button.visible = true
		right_button.visible = true
		left_button.position = Vector2(90, 820)
		right_button.position = Vector2(510, 820)

func change_food_pair():
	var new_saudavel_index: int
	var new_nao_saudavel_index: int
	
	if max_saudaveis > 0:
		new_saudavel_index = randi() % max_saudaveis
		while new_saudavel_index == prev_saudavel_index and max_saudaveis > 1:
			new_saudavel_index = randi() % max_saudaveis
		current_saudavel_index = new_saudavel_index
		prev_saudavel_index = new_saudavel_index
	else:
		print("Erro: Nenhuma comida saudável disponível!")
	
	if max_nao_saudaveis > 0:
		new_nao_saudavel_index = randi() % max_nao_saudaveis
		while new_nao_saudavel_index == prev_nao_saudavel_index and max_nao_saudaveis > 1:
			new_nao_saudavel_index = randi() % max_nao_saudaveis
		current_nao_saudavel_index = new_nao_saudavel_index
		prev_nao_saudavel_index = new_nao_saudavel_index
	else:
		print("Erro: Nenhuma comida não saudável disponível!")
	
	print("Novo par: Saudável índice ", current_saudavel_index, ", Não Saudável índice ", current_nao_saudavel_index)

func _on_info_button_pressed():
	print("InfoButton pressionado! Plataforma: ", OS.get_name())  # Depura para ver se chamado no mobile
	var error = get_tree().change_scene_to_file("res://Cenas/Info.tscn")
	if error != OK:
		print("Erro ao carregar info.tscn: ", error)
	else:
		print("Cena info.tscn carregada com sucesso!")

func _on_menu_button_pressed():
	print("MenuButton pressionado! Reiniciando jogo.")
	get_tree().paused = false
	reset_game_state()

func reset_game_state():
	print("Reiniciando estado do jogo...")
	countdown = 3
	game_started = false
	current_saudavel_index = 0
	current_nao_saudavel_index = 0
	prev_saudavel_index = -1
	prev_nao_saudavel_index = -1
	current_fall_speed = base_fall_speed
	current_player_speed = base_player_speed  # Reset da velocidade do jogador
	current_spawn_wait = base_spawn_wait
	if has_node("Player"):
		$Player.pontos = 0
		$Player.vidas = 3
		$Player.position = Vector2(300, 800)
		$Player.velocidade = base_player_speed  # Garante reset da velocidade no Player
		$Player.set_process(false)
		$Player.visible = true
		print("Player reiniciado: pontos = ", $Player.pontos, ", vidas = ", $Player.vidas, ", visível = ", $Player.visible, ", velocidade = ", $Player.velocidade)
	if $UILayer/PontosLabel:
		$UILayer/PontosLabel.text = "Pontos: 0"
		$UILayer/PontosLabel.visible = true  # Restaurar visibilidade
		print("PontosLabel reiniciado: visível = ", $UILayer/PontosLabel.visible)
	if $UILayer/VidasLabel:
		$UILayer/VidasLabel.text = "Vidas: 3"
		$UILayer/VidasLabel.visible = true  # Restaurar visibilidade
		print("VidasLabel reiniciado: visível = ", $UILayer/VidasLabel.visible)
	if $SpawnerComida and $SpawnerComida.has_node("SpawnTimer"):
		$SpawnerComida/SpawnTimer.stop()  # Para qualquer timeout pendente
		$SpawnerComida/SpawnTimer.wait_time = base_spawn_wait  # Reseta wait_time base
		$SpawnerComida/SpawnTimer.paused = true  # Corrige para pausar, evitando spawns no menu
		if $SpawnerComida/SpawnTimer.is_stopped():
			$SpawnerComida/SpawnTimer.start()  # Inicia pausado, como no _ready()
		print("SpawnTimer resetado: wait_time = ", base_spawn_wait, ", paused = ", $SpawnerComida/SpawnTimer.paused)
	# Adicionado: Remove todas as comidas existentes pra evitar amontoamento
	for comida in get_tree().get_nodes_in_group("comida"):
		comida.queue_free()
	print("Todas as comidas removidas")
	if $BackgroundBlurred:
		$BackgroundBlurred.visible = true
	if $BackgroundNormal:
		$BackgroundNormal.visible = false
	if $UILayer/GameOverLabel:
		$UILayer/GameOverLabel.visible = false
	if $UILayer/FinalScoreLabel:
		$UILayer/FinalScoreLabel.visible = false
	if $UILayer/MenuButton:
		$UILayer/MenuButton.visible = false
		$UILayer/MenuButton.disabled = false
		print("MenuButton escondido, disabled = ", $UILayer/MenuButton.disabled)
	if left_button and right_button:
		left_button.visible = false
		right_button.visible = false
	if $MenuLayer:
		$MenuLayer.visible = true
	if background_music:
		background_music.volume_db = -10.0
		background_music.play()
		print("Música de fundo reiniciada")

func center_buttons():
	var screen_width = get_viewport_rect().size.x
	var start_button = $MenuLayer/StartButton if $MenuLayer and $MenuLayer.has_node("StartButton") else null
	var info_button = $MenuLayer/InfoButton if $MenuLayer and $MenuLayer.has_node("InfoButton") else null
	if start_button:
		start_button.position.x = screen_width / 2 - start_button.size.x / 2
	if info_button:
		info_button.position.x = screen_width / 2 - info_button.size.x / 2  # Centraliza usando size do Button diretamente

func show_game_over():
	print("Exibindo tela de Game Over")
	if background_music:
		background_music.stop()
	
	if has_node("Player"):
		$Player.set_process(false)
		$Player.visible = false
	if $SpawnerComida and $SpawnerComida.has_node("SpawnTimer"):
		$SpawnerComida/SpawnTimer.stop()  # Para timeouts pendentes
		$SpawnerComida/SpawnTimer.paused = true
	
	for comida in get_tree().get_nodes_in_group("comida"):
		comida.queue_free()
	
	if $BackgroundBlurred:
		$BackgroundBlurred.visible = true
	if $BackgroundNormal:
		$BackgroundNormal.visible = false
	
	var viewport_size = get_viewport_rect().size
	var game_over_label = $UILayer/GameOverLabel if $UILayer and $UILayer.has_node("GameOverLabel") else null
	if game_over_label:
		game_over_label.position = Vector2(viewport_size.x / 2 - game_over_label.size.x / 2, viewport_size.y / 2 - 100)
		game_over_label.visible = true
	
	var final_score_label = $UILayer/FinalScoreLabel if $UILayer and $UILayer.has_node("FinalScoreLabel") else null
	if final_score_label:
		var pontos = $Player.pontos if has_node("Player") else 0
		final_score_label.text = "Pontos: " + str(pontos)
		await get_tree().process_frame
		var text_rect = final_score_label.get_rect()
		final_score_label.size = text_rect.size
		final_score_label.position = Vector2(viewport_size.x / 2 - text_rect.size.x / 2, 50)
		final_score_label.visible = true
	
	var menu_button = $UILayer/MenuButton if $UILayer and $UILayer.has_node("MenuButton") else null
	if menu_button:
		menu_button.position = Vector2(viewport_size.x / 2 - menu_button.size.x / 2, viewport_size.y / 2 + 50)
		menu_button.visible = true
		menu_button.disabled = false
		print("MenuButton ativado: posição = ", menu_button.position)
	
	if $UILayer/PontosLabel:
		$UILayer/PontosLabel.visible = false
	if $UILayer/VidasLabel:
		$UILayer/VidasLabel.visible = false
	if left_button and right_button:
		left_button.visible = false
		right_button.visible = false

func _on_left_button_pressed():
	Input.action_press("ui_left")

func _on_left_button_released():
	Input.action_release("ui_left")

func _on_right_button_pressed():
	Input.action_press("ui_right")

func _on_right_button_released():
	Input.action_release("ui_right")
