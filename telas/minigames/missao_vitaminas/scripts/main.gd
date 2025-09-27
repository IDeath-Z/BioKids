extends Control

var original_width: float = 600
var original_height: float = 900
var scale_factor: float  # Uniforme pra X e Y
var screen_size: Vector2

var countdown = 3
var game_started = false
var current_saudavel_index: int = 0
var current_nao_saudavel_index: int = 0
var prev_saudavel_index: int = -1
var prev_nao_saudavel_index: int = -1
var musica_ligada_original: bool = true

# Variáveis @onready para inicialização segura
@onready var max_saudaveis: int = load("res://telas/minigames/missao_vitaminas/Cenas/comida_saudavel.tscn").instantiate().sprites_saudaveis.size() if ResourceLoader.exists("res://Cenas/comida_saudavel.tscn") else 0
@onready var max_nao_saudaveis: int = load("res://telas/minigames/missao_vitaminas/Cenas/comida_nao_saudavel.tscn").instantiate().sprites_nao_saudaveis.size() if ResourceLoader.exists("res://Cenas/comida_nao_saudavel.tscn") else 0
@onready var background_music = $UILayer/BackgroundMusic if has_node("UILayer/BackgroundMusic") else null
@onready var left_button = $UILayer/TouchControls/LeftButton if has_node("UILayer/TouchControls/LeftButton") else null
@onready var right_button = $UILayer/TouchControls/RightButton if has_node("UILayer/TouchControls/RightButton") else null

# Variáveis para controlar a velocidade de queda dos alimentos
var base_fall_speed: float
var fall_speed_increment: float
var max_fall_speed: float
var current_fall_speed: float

# Variáveis para controlar a velocidade do player
var base_player_speed: float
var player_speed_increment: float
var max_player_speed: float
var current_player_speed: float

# Variáveis para controlar o intervalo de spawn
var base_spawn_wait: float = 1.0
var min_spawn_wait: float = 0.3
var current_spawn_wait: float

func _ready():
	screen_size = get_viewport_rect().size
	scale_factor = screen_size.x / original_width  # 1.2, uniforme

	# Salva o estado original da música e para a música da home
	if EstadoVariaveisGlobais:
		musica_ligada_original = EstadoVariaveisGlobais.musica_ligada
		EstadoVariaveisGlobais.musica_ligada = false
		print("Música da home desativada via EstadoVariaveisGlobais! Estado original: ", musica_ligada_original)
	else:
		print("Erro: EstadoVariaveisGlobais não encontrado! Tentando parar música diretamente...")
		var music_player = get_node_or_null("/root/MusicPlayer/AudioStreamPlayer")
		if music_player:
			music_player.stop()
			print("Música da home parada diretamente via MusicPlayer!")
		else:
			print("Erro: MusicPlayer/AudioStreamPlayer não encontrado!")

	# ... (código existente para ajuste de velocidades, etc.)

	# Inicia a música de fundo do jogo apenas se musica_ligada_original for true
	if background_music and musica_ligada_original:
		background_music.volume_db = -10.0
		background_music.play()
		background_music.finished.connect(func(): background_music.play())
		print("Música de fundo iniciada com volume -10.0 dB")
	else:
		if not background_music:
			print("Erro: BackgroundMusic não encontrado!")
		else:
			print("Música do jogo não iniciada porque musica_ligada_original é false")
	# ... (restante do _ready)


	# Ajusta velocidades base proporcionalmente
	base_fall_speed = 200.0 * scale_factor
	fall_speed_increment = 50.0 * scale_factor
	max_fall_speed = 1000.0 * scale_factor
	current_fall_speed = base_fall_speed

	base_player_speed = 240.0 * scale_factor
	player_speed_increment = 20.0 * scale_factor
	max_player_speed = 400.0 * scale_factor
	current_player_speed = base_player_speed

	current_spawn_wait = base_spawn_wait
	
	$Player.position = Vector2(screen_size.x / 2, screen_size.y - 100 * scale_factor)

	# Seleciona o par inicial aleatoriamente
	if max_saudaveis > 0 and max_nao_saudaveis > 0:
		change_food_pair()
	else:
		print("Erro: Cenas de comida não carregadas ou sem sprites!")

	
	# Conecta os sinais dos botões
	var start_button = $MenuLayer/StartButton if $MenuLayer and $MenuLayer.has_node("StartButton") else null
	if start_button:
		start_button.pressed.connect(_on_start_button_pressed)
		start_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		start_button.focus_mode = Control.FOCUS_ALL
		start_button.mouse_filter = Control.MOUSE_FILTER_STOP
		start_button.disabled = false
	else:
		print("Erro: StartButton não encontrado!")

	var info_button = $MenuLayer/InfoButton if $MenuLayer and $MenuLayer.has_node("InfoButton") else null
	if info_button:
		info_button.pressed.connect(_on_info_button_pressed)
		info_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		info_button.focus_mode = Control.FOCUS_ALL
		info_button.mouse_filter = Control.MOUSE_FILTER_STOP
		info_button.disabled = false
	else:
		print("Erro: InfoButton não encontrado!")


	var menu_button = $UILayer/MenuButton if $UILayer and $UILayer.has_node("MenuButton") else null
	if menu_button:
		if menu_button.pressed.is_connected(_on_menu_button_pressed):
			menu_button.pressed.disconnect(_on_menu_button_pressed)
		menu_button.pressed.connect(_on_menu_button_pressed)
		menu_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		menu_button.visible = false
		menu_button.disabled = false
		print("MenuButton conectado: visible = ", menu_button.visible, ", disabled = ", menu_button.disabled)
	else:
		print("Erro: MenuButton não encontrado!")
		

	var voltar_button = $MenuLayer/VoltarButton if $MenuLayer and $MenuLayer.has_node("VoltarButton") else null
	if voltar_button:
		voltar_button.pressed.connect(_on_voltar_button_pressed)
		voltar_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		voltar_button.focus_mode = Control.FOCUS_ALL
		voltar_button.mouse_filter = Control.MOUSE_FILTER_STOP
		voltar_button.disabled = false
		print("VoltarButton conectado: visible = ", voltar_button.visible, ", disabled = ", voltar_button.disabled)
	else:
		print("Erro: VoltarButton não encontrado!")


	var spawn_timer = $SpawnerComida/SpawnTimer if $SpawnerComida and $SpawnerComida.has_node("SpawnTimer") else null
	if spawn_timer:
		spawn_timer.wait_time = current_spawn_wait
		spawn_timer.paused = true
		if spawn_timer.is_stopped():
			spawn_timer.start()
	else:
		print("Erro: SpawnTimer não encontrado!")


	if has_node("Player"):
		$Player.set_process(false)
	else:
		print("Erro: Player não encontrado!")


	if $BackgroundBlurred:
		$BackgroundBlurred.visible = true
	else:
		print("Erro: BackgroundBlurred não encontrado!")
	if $BackgroundNormal:
		$BackgroundNormal.visible = false
	else:
		print("Erro: BackgroundNormal não encontrado!")


	var pontos_label = $UILayer/PontosLabel if $UILayer and $UILayer.has_node("PontosLabel") else null
	if pontos_label:
		pontos_label.text = "Pontos: 0"
		pontos_label.position = Vector2(20 * scale_factor, 20 * scale_factor)  # Canto superior esquerdo
	else:
		print("Erro: PontosLabel não encontrado!")

	var vidas_label = $UILayer/VidasLabel if $UILayer and $UILayer.has_node("VidasLabel") else null
	if vidas_label:
		vidas_label.text = "Vidas: 3"
		vidas_label.position = Vector2(screen_size.x - 170 * scale_factor, 20 * scale_factor)  # Canto superior direito
	else:
		print("Erro: VidasLabel não encontrado!")


	var countdown_label = $UILayer/CountdownLabel if $UILayer and $UILayer.has_node("CountdownLabel") else null
	if countdown_label:
		countdown_label.visible = false
	else:
		print("Erro: CountdownLabel não encontrado!")


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
		var rect_texto = final_score_label.get_rect()
		final_score_label.size = rect_texto.size
		final_score_label.text = ""
		print("FinalScoreLabel inicializado, tamanho: ", rect_texto.size)
	else:
		print("Erro: FinalScoreLabel não encontrado!")

	if $UILayer/CountdownTickSound:
		print("CountdownTickSound encontrado")
	else:
		print("Erro: CountdownTickSound não encontrado!")
	if $UILayer/StartRaceSound:
		print("StartRaceSound encontrado")
	else:
		print("Erro: StartRaceSound não encontrado!")

	center_buttons()

	if left_button and right_button:
		left_button.visible = false
		right_button.visible = false
		left_button.position = Vector2(90 * scale_factor, screen_size.y - 80 * scale_factor)
		right_button.position = Vector2((original_width - 90) * scale_factor, screen_size.y - 80 * scale_factor)
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
	
	countdown_label.position = Vector2(120, 490)
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
		left_button.position = Vector2(90 * scale_factor, screen_size.y - 80 * scale_factor)
		right_button.position = Vector2((original_width - 90) * scale_factor, screen_size.y - 80 * scale_factor)

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
	print("InfoButton pressionado! Plataforma: ", OS.get_name())
	var erro = get_tree().change_scene_to_file("res://telas/minigames/missao_vitaminas/Cenas/Info.tscn")
	if erro != OK:
		print("Erro ao carregar Info.tscn: ", erro)
	else:
		print("Cena Info.tscn carregada com sucesso!")

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
	current_player_speed = base_player_speed
	current_spawn_wait = base_spawn_wait
	if has_node("Player"):
		$Player.pontos = 0
		$Player.vidas = 3
		$Player.position = Vector2(screen_size.x / 2, screen_size.y - 100 * scale_factor)
		$Player.velocidade = base_player_speed
		$Player.set_process(false)
		$Player.visible = true
		print("Player reiniciado: pontos = ", $Player.pontos, ", vidas = ", $Player.vidas, ", visible = ", $Player.visible, ", velocidade = ", $Player.velocidade)
	if $UILayer/PontosLabel:
		$UILayer/PontosLabel.text = "Pontos: 0"
		$UILayer/PontosLabel.visible = true
		print("PontosLabel reiniciado: visible = ", $UILayer/PontosLabel.visible)
	if $UILayer/VidasLabel:
		$UILayer/VidasLabel.text = "Vidas: 3"
		$UILayer/VidasLabel.visible = true
		print("VidasLabel reiniciado: visible = ", $UILayer/VidasLabel.visible)
	if $SpawnerComida and $SpawnerComida.has_node("SpawnTimer"):
		$SpawnerComida/SpawnTimer.stop()
		$SpawnerComida/SpawnTimer.wait_time = base_spawn_wait
		$SpawnerComida/SpawnTimer.paused = true
		if $SpawnerComida/SpawnTimer.is_stopped():
			$SpawnerComida/SpawnTimer.start()
		print("SpawnTimer resetado: wait_time = ", base_spawn_wait, ", paused = ", $SpawnerComida/SpawnTimer.paused)
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
	if background_music and musica_ligada_original:
		background_music.volume_db = -10.0
		background_music.play()
		print("Música de fundo reiniciada")
	else:
		print("Música do jogo não reiniciada porque musica_ligada_original é false")

func center_buttons():
	var start_button = $MenuLayer/StartButton if $MenuLayer and $MenuLayer.has_node("StartButton") else null
	var info_button = $MenuLayer/InfoButton if $MenuLayer and $MenuLayer.has_node("InfoButton") else null
	var voltar_button = $MenuLayer/VoltarButton if $MenuLayer and $MenuLayer.has_node("VoltarButton") else null
	if start_button:
		start_button.position = Vector2(180, 400)
		print("StartButton posição: ", start_button.position)
	if info_button:
		info_button.position = Vector2(180, 570)
		print("InfoButton posição: ", info_button.position)
	if voltar_button:
		voltar_button.position = Vector2(180, 740)
		print("VoltarButton posição: ", voltar_button.position)

func show_game_over():
	print("Exibindo tela de Game Over")
	if background_music:
		background_music.stop()
	
	if has_node("Player"):
		$Player.set_process(false)
		$Player.visible = false
	if $SpawnerComida and $SpawnerComida.has_node("SpawnTimer"):
		$SpawnerComida/SpawnTimer.stop()
		$SpawnerComida/SpawnTimer.paused = true
	
	for comida in get_tree().get_nodes_in_group("comida"):
		comida.queue_free()
	
	if $BackgroundBlurred:
		$BackgroundBlurred.visible = true
	if $BackgroundNormal:
		$BackgroundNormal.visible = false
	
	var game_over_label = $UILayer/GameOverLabel if $UILayer and $UILayer.has_node("GameOverLabel") else null
	if game_over_label:
		await get_tree().process_frame
		game_over_label.position = Vector2(138, 480)
		game_over_label.visible = true
	
	var final_score_label = $UILayer/FinalScoreLabel if $UILayer and $UILayer.has_node("FinalScoreLabel") else null
	if final_score_label:
		var pontos = $Player.pontos if has_node("Player") else 0
		final_score_label.text = "Pontos: " + str(pontos)
		await get_tree().process_frame
		var rect_texto = final_score_label.get_rect()
		final_score_label.size = rect_texto.size
		final_score_label.position = Vector2(336 - rect_texto.size.x / 2, 50) 
		final_score_label.visible = true
	
	var menu_button = $UILayer/MenuButton if $UILayer and $UILayer.has_node("MenuButton") else null
	if menu_button:
		await get_tree().process_frame
		menu_button.position = Vector2(72, 630)  # Alterado para 630y
		menu_button.visible = true
		menu_button.disabled = false
		print("MenuButton ativado: position = ", menu_button.position)
	
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

func _on_voltar_button_pressed():
	print("VoltarButton pressionado!")
	
	# Para a música do jogo
	if background_music:
		background_music.stop()
		print("Música do jogo parada!")
	else:
		print("Erro: BackgroundMusic não encontrado!")
	
	# Restaura o estado original da música da home
	if EstadoVariaveisGlobais:
		EstadoVariaveisGlobais.musica_ligada = musica_ligada_original
		print("Música da home restaurada para estado original: ", musica_ligada_original)
	else:
		print("Erro: EstadoVariaveisGlobais não encontrado! Tentando iniciar música diretamente...")
		var music_player = get_node_or_null("/root/MusicPlayer")
		if music_player and musica_ligada_original:
			music_player.play_music()
			print("Música da home iniciada diretamente via MusicPlayer!")
		else:
			if not music_player:
				print("Erro: MusicPlayer não encontrado!")
			else:
				print("Música da home não iniciada porque musica_ligada_original é false")
	
	# Muda para a cena da home
	var scene_path = "res://telas/interface/selecaoMiniGame/tela_selecao_mini_game.tscn"
	var erro = get_tree().change_scene_to_file(scene_path)
	if erro != OK:
		print("Erro ao carregar cena ", scene_path, ": ", erro)
	else:
		print("Cena ", scene_path, " carregada com sucesso!")
