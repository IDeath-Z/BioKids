extends Control

var original_width: float = 600
var original_height: float = 900
var scale_factor: float
var screen_size: Vector2
var last_score_threshold: int = 0

var countdown = 3
var game_started = false
var current_saudavel_index: int = 0
var current_nao_saudavel_index: int = 0
var prev_saudavel_index: int = -1
var prev_nao_saudavel_index: int = -1
var musica_ligada_original: bool = true

@onready var max_saudaveis: int = preload("res://telas/minigames/missao_vitaminas/Cenas/comida_saudavel.tscn").instantiate().sprites_saudaveis.size()
@onready var max_nao_saudaveis: int = preload("res://telas/minigames/missao_vitaminas/Cenas/comida_nao_saudavel.tscn").instantiate().sprites_nao_saudaveis.size()
@onready var background_music = $UILayer/BackgroundMusic if has_node("UILayer/BackgroundMusic") else null
@onready var left_button = $UILayer/TouchControls/LeftButton if has_node("UILayer/TouchControls/LeftButton") else null
@onready var right_button = $UILayer/TouchControls/RightButton if has_node("UILayer/TouchControls/RightButton") else null
@onready var bio_fato_scene = preload("res://telas/minigames/missao_vitaminas/Cenas/bio_fato_vitaminas.tscn")

var base_fall_speed: float
var fall_speed_increment: float
var max_fall_speed: float
var current_fall_speed: float

var base_player_speed: float
var player_speed_increment: float
var max_player_speed: float
var current_player_speed: float

var base_spawn_wait: float = 1.0
var min_spawn_wait: float = 0.3
var current_spawn_wait: float

func _ready():
	randomize()
	screen_size = get_viewport_rect().size
	scale_factor = screen_size.x / original_width

	# Remove qualquer comida existente na inicialização
	for comida in get_tree().get_nodes_in_group("comida"):
		comida.queue_free()
		print("Comida residual removida no _ready")

	if EstadoVariaveisGlobais:
		if not EstadoVariaveisGlobais.in_minigame_vitaminas:
			EstadoVariaveisGlobais.in_minigame_vitaminas = true
			musica_ligada_original = EstadoVariaveisGlobais.musica_ligada
			EstadoVariaveisGlobais.minigame_vitaminas_music_on = musica_ligada_original
			EstadoVariaveisGlobais.musica_ligada = false
			print("Primeira entrada no minigame: Música da home desativada via EstadoVariaveisGlobais! Estado original salvo: ", musica_ligada_original)
		else:
			musica_ligada_original = EstadoVariaveisGlobais.minigame_vitaminas_music_on
			print("Retorno da info: Estado da música restaurado do global: ", musica_ligada_original)
	else:
		print("Erro: EstadoVariaveisGlobais não encontrado! Tentando parar música diretamente...")
		var music_player = get_node_or_null("/root/MusicPlayer/AudioStreamPlayer")
		if music_player:
			music_player.stop()
			print("Música da home parada diretamente via MusicPlayer!")
		else:
			print("Erro: MusicPlayer/AudioStreamPlayer não encontrado!")

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

	if max_saudaveis > 0 and max_nao_saudaveis > 0:
		change_food_pair() # Define os índices iniciais, mas não spawna
	else:
		print("Erro: Cenas de comida não carregadas ou sem sprites!")

	if has_node("Player"):
		$Player.connect("score_changed", Callable(self, "update_food_pair_based_on_score"))
	
	# Configuração do MarginContainer e VBoxContainer
	var margin_container = $MenuLayer/MarginContainer
	if margin_container:
		margin_container.set_anchors_preset(Control.PRESET_CENTER)
		margin_container.add_theme_constant_override("margin_left", 20 * scale_factor)
		margin_container.add_theme_constant_override("margin_right", 20 * scale_factor)
		margin_container.add_theme_constant_override("margin_top", 20 * scale_factor)
		margin_container.add_theme_constant_override("margin_bottom", 20 * scale_factor)
		margin_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		margin_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
		print("MarginContainer configurado: anchors = Center, margins = ", 20 * scale_factor)

	var vbox = $MenuLayer/MarginContainer/VBoxContainer
	if vbox:
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		print("VBoxContainer configurado: alignment = Center")

	# Configuração dos botões
	var start_button = $MenuLayer/MarginContainer/VBoxContainer/StartButton
	if start_button:
		start_button.pressed.connect(_on_start_button_pressed)
		start_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		start_button.focus_mode = Control.FOCUS_ALL
		start_button.mouse_filter = Control.MOUSE_FILTER_STOP
		start_button.disabled = false
		start_button.size = Vector2(200 * scale_factor, 50 * scale_factor)
		start_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		start_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		print("StartButton configurado: size = ", start_button.size)
	else:
		print("Erro: StartButton não encontrado!")

	var info_button = $MenuLayer/MarginContainer/VBoxContainer/InfoButton
	if info_button:
		info_button.pressed.connect(_on_info_button_pressed)
		info_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		info_button.focus_mode = Control.FOCUS_ALL
		info_button.mouse_filter = Control.MOUSE_FILTER_STOP
		info_button.disabled = false
		info_button.size = Vector2(200 * scale_factor, 50 * scale_factor)
		info_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		info_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		print("InfoButton configurado: size = ", info_button.size)
	else:
		print("Erro: InfoButton não encontrado!")

	var voltar_button = $MenuLayer/MarginContainer/VBoxContainer/VoltarButton
	if voltar_button:
		voltar_button.pressed.connect(_on_voltar_button_pressed)
		voltar_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		voltar_button.focus_mode = Control.FOCUS_ALL
		voltar_button.mouse_filter = Control.MOUSE_FILTER_STOP
		voltar_button.disabled = false
		voltar_button.size = Vector2(200 * scale_factor, 50 * scale_factor)
		voltar_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		voltar_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		print("VoltarButton configurado: size = ", voltar_button.size)
	else:
		print("Erro: VoltarButton não encontrado!")

	var menu_button = $UILayer/MenuButton
	if menu_button:
		if menu_button.pressed.is_connected(_on_menu_button_pressed):
			menu_button.pressed.disconnect(_on_menu_button_pressed)
		menu_button.pressed.connect(_on_menu_button_pressed)
		menu_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		menu_button.focus_mode = Control.FOCUS_ALL
		menu_button.mouse_filter = Control.MOUSE_FILTER_STOP
		menu_button.visible = false
		menu_button.disabled = false
		print("MenuButton conectado: visible = ", menu_button.visible, ", disabled = ", menu_button.disabled)
	else:
		print("Erro: MenuButton não encontrado!")

	var spawn_timer = $SpawnerComida/SpawnTimer
	if spawn_timer:
		spawn_timer.wait_time = current_spawn_wait
		spawn_timer.paused = true
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

	var pontos_label = $UILayer/PontosLabel
	if pontos_label:
		pontos_label.text = "Pontos: 0"
		pontos_label.position = Vector2(20 * scale_factor, 20 * scale_factor)
	else:
		print("Erro: PontosLabel não encontrado!")

	var vidas_label = $UILayer/VidasLabel
	if vidas_label:
		vidas_label.text = "Vidas: 3"
		vidas_label.position = Vector2(screen_size.x - 170 * scale_factor, 20 * scale_factor)
	else:
		print("Erro: VidasLabel não encontrado!")

	var countdown_label = $UILayer/CountdownLabel
	if countdown_label:
		countdown_label.visible = false
	else:
		print("Erro: CountdownLabel não encontrado!")

	var game_over_label = $UILayer/GameOverLabel
	if game_over_label:
		game_over_label.visible = false
	else:
		print("Erro: GameOverLabel não encontrado!")

	var final_score_label = $UILayer/FinalScoreLabel
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
	
	var spawn_timer = $SpawnerComida/SpawnTimer
	if spawn_timer:
		spawn_timer.wait_time = current_spawn_wait
	print("Intervalo de spawn ajustado para: ", current_spawn_wait)

func _on_start_button_pressed():
	if $MenuLayer:
		$MenuLayer.visible = false
	start_countdown()

func start_countdown() -> void:
	var countdown_label = $UILayer/CountdownLabel
	if not countdown_label:
		print("Erro: CountdownLabel não encontrado!")
		return
	
	if background_music:
		background_music.volume_db = -20.0
		print("Volume da música reduzido para -20.0 dB")
	
	countdown_label.visible = true
	# countdown_label.position = Vector2(screen_size.x / 2 - 50, screen_size.y / 2 - 25)
	
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
		$SpawnerComida/SpawnTimer.paused = false
		if $SpawnerComida/SpawnTimer.is_stopped():
			$SpawnerComida/SpawnTimer.start()
			print("SpawnTimer iniciado após contagem regressiva")
	
	if left_button and right_button:
		left_button.visible = true
		right_button.visible = true
		left_button.position = Vector2(90 * scale_factor, screen_size.y - 80 * scale_factor)
		right_button.position = Vector2((original_width - 90) * scale_factor, screen_size.y - 80 * scale_factor)
	
	# Spawna os dois alimentos iniciais após a contagem regressiva
	spawn_initial_food_pair()

func spawn_initial_food_pair():
	if not game_started:
		print("spawn_initial_food_pair bloqueado: game_started é false")
		return
	
	var spawner = $SpawnerComida
	if spawner:
		# Remove qualquer comida existente para evitar duplicatas
		for comida in get_tree().get_nodes_in_group("comida"):
			comida.queue_free()
		
		var comida_saudavel = preload("res://telas/minigames/missao_vitaminas/Cenas/comida_saudavel.tscn").instantiate()
		comida_saudavel.sprite_index = current_saudavel_index
		comida_saudavel.velocidade_queda = current_fall_speed
		comida_saudavel.position = Vector2(randf_range(10, screen_size.x / 2 - 10), 0)
		spawner.add_child(comida_saudavel)
		print("Comida saudável inicial spawnada com índice: ", current_saudavel_index)

		var comida_nao_saudavel = preload("res://telas/minigames/missao_vitaminas/Cenas/comida_nao_saudavel.tscn").instantiate()
		comida_nao_saudavel.sprite_index = current_nao_saudavel_index
		comida_nao_saudavel.velocidade_queda = current_fall_speed
		comida_nao_saudavel.position = Vector2(randf_range(screen_size.x / 2 + 10, screen_size.x - 10), 0)
		spawner.add_child(comida_nao_saudavel)
		print("Comida não saudável inicial spawnada com índice: ", current_nao_saudavel_index)

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

	print("Novo par definido: Saudável índice ", current_saudavel_index, ", Não Saudável índice ", current_nao_saudavel_index)

func _on_info_button_pressed():
	print("InfoButton pressionado! Plataforma: ", OS.get_name())
	var erro = get_tree().change_scene_to_file("res://telas/minigames/missao_vitaminas/Cenas/Info.tscn")
	if erro != OK:
		print("Erro ao carregar Info.tscn: ", erro)
	else:
		print("Cena Info.tscn carregada com sucesso!")

func _on_menu_button_pressed():
	print("MenuButton pressionado! Mostrando Bio Fato.")
	get_tree().paused = false
	
	if $UILayer/GameOverLabel:
		$UILayer/GameOverLabel.visible = false
	if $UILayer/FinalScoreLabel:
		$UILayer/FinalScoreLabel.visible = false
	if $UILayer/MenuButton:
		$UILayer/MenuButton.visible = false
		$UILayer/MenuButton.set_process_input(false)
	
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 10 # Garantir que o bio_fato fique acima do MenuLayer
	add_child(canvas_layer)
	
	var bio_fato = bio_fato_scene.instantiate()
	canvas_layer.add_child(bio_fato)
	
	bio_fato.z_index = 100
	
	await get_tree().process_frame
	
	if bio_fato.has_node("BioFato/BotaoContinuar"):
		var botao = bio_fato.get_node("BioFato/BotaoContinuar")
		botao.grab_focus()
		botao.mouse_filter = Control.MOUSE_FILTER_STOP
		print("Foco dado ao BotaoContinuar! Mouse Filter: ", botao.mouse_filter)
		if botao.mouse_filter != Control.MOUSE_FILTER_STOP:
			print("Aviso: Mouse Filter não foi alterado para STOP!")
	else:
		print("Erro: BotaoContinuar não encontrado na hierarquia!")
	
	print("Bio fato instanciado e configurado!")

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
	var margin_container = $MenuLayer/MarginContainer
	if margin_container:
		margin_container.set_anchors_preset(Control.PRESET_CENTER)
		margin_container.add_theme_constant_override("margin_left", 20 * scale_factor)
		margin_container.add_theme_constant_override("margin_right", 20 * scale_factor)
		margin_container.add_theme_constant_override("margin_top", 20 * scale_factor)
		margin_container.add_theme_constant_override("margin_bottom", 20 * scale_factor)
		print("MarginContainer recentralizado: margins = ", 20 * scale_factor)

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
	
	var game_over_label = $UILayer/GameOverLabel
	if game_over_label:
		await get_tree().process_frame
		game_over_label.position = Vector2(138 * scale_factor, 480 * scale_factor)
		game_over_label.visible = true
	
	var final_score_label = $UILayer/FinalScoreLabel
	if final_score_label:
		var pontos = $Player.pontos if has_node("Player") else 0
		final_score_label.text = "Pontos: " + str(pontos)
		await get_tree().process_frame
		var rect_texto = final_score_label.get_rect()
		final_score_label.size = rect_texto.size
		final_score_label.position = Vector2(screen_size.x / 2 - rect_texto.size.x / 2, 50 * scale_factor)
		final_score_label.visible = true
	
	var menu_button = $UILayer/MenuButton
	if menu_button:
		await get_tree().process_frame
		#menu_button.position = Vector2(72 * scale_factor, 630 * scale_factor)
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
	
	if background_music:
		background_music.stop()
		print("Música do jogo parada!")
	else:
		print("Erro: BackgroundMusic não encontrado!")
	
	if EstadoVariaveisGlobais:
		EstadoVariaveisGlobais.musica_ligada = EstadoVariaveisGlobais.minigame_vitaminas_music_on
		EstadoVariaveisGlobais.in_minigame_vitaminas = false
		EstadoVariaveisGlobais.minigame_vitaminas_music_on = false
		print("Música da home restaurada para estado original: ", EstadoVariaveisGlobais.musica_ligada)
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
	
	var scene_path = "res://telas/interface/selecaoMiniGame/tela_selecao_mini_game.tscn"
	var erro = get_tree().change_scene_to_file(scene_path)
	if erro != OK:
		print("Erro ao carregar cena ", scene_path, ": ", erro)
	else:
		print("Cena ", scene_path, " carregada com sucesso!")

func update_food_pair_based_on_score(new_score: int) -> void:
	var new_threshold = int(new_score / 100) * 100
	if new_threshold > last_score_threshold:
		change_food_pair()
		last_score_threshold = new_threshold
		increase_fall_speed()
		increase_player_speed()
		decrease_spawn_wait()
		print("Novo par de alimentos gerado em ", new_score, " pontos!")
