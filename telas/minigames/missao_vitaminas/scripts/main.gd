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
@onready var pause_container = $UILayer/PauseMarginContainer if has_node("UILayer/PauseMarginContainer") else null
@onready var pause_button = $UILayer/PauseMarginContainer/PauseButton if has_node("UILayer/PauseMarginContainer/PauseButton") else null
@onready var pause_menu_node = $UILayer/PauseMenuNode if has_node("UILayer/PauseMenuNode") else null
@onready var pause_menu = $UILayer/PauseMenuNode/PauseMenu if has_node("UILayer/PauseMenuNode/PauseMenu") else null
@onready var menu_button = $UILayer/MenuButton if has_node("UILayer/MenuButton") else null

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
		change_food_pair()
	else:
		print("Erro: Cenas de comida não carregadas ou sem sprites!")

	if has_node("Player"):
		$Player.connect("score_changed", Callable(self, "update_food_pair_based_on_score"))
	
	# Configuração do MarginContainer do MenuLayer
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

	# Configuração dos botões do menu inicial
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
	else:
		print("Erro: PontosLabel não encontrado!")

	var vidas_label = $UILayer/VidasLabel
	if vidas_label:
		vidas_label.text = "Vidas: 3"
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

	if pause_container:
		pause_container.visible = false
		pause_container.set_anchors_preset(Control.PRESET_TOP_LEFT)
		pause_container.z_index = 10
		pause_container.add_theme_constant_override("margin_left", 10 * scale_factor)
		pause_container.add_theme_constant_override("margin_top", 10 * scale_factor)
		print("PauseMarginContainer inicializado: visible = ", pause_container.visible, ", z_index = ", pause_container.z_index)
	else:
		print("Erro: PauseMarginContainer não encontrado!")

	if pause_button:
		pause_button.process_mode = Node.PROCESS_MODE_ALWAYS  # Garante que processe eventos mesmo pausado
		pause_button.modulate = Color(1.0, 1.0, 1.0)
		pause_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		pause_button.focus_mode = Control.FOCUS_ALL
		pause_button.mouse_filter = Control.MOUSE_FILTER_STOP
		pause_button.disabled = false
		pause_button.z_index = 11
	if not pause_button.pressed.is_connected(_on_pause_button_pressed):
		pause_button.pressed.connect(_on_pause_button_pressed)
		print("Sinal pressed do PauseButton conectado!")
	if not pause_button.mouse_entered.is_connected(_on_pause_button_mouse_entered):
		pause_button.mouse_entered.connect(_on_pause_button_mouse_entered)
		print("Sinal mouse_entered do PauseButton conectado!")
	if not pause_button.mouse_exited.is_connected(_on_pause_button_mouse_exited):
		pause_button.mouse_exited.connect(_on_pause_button_mouse_exited)
		print("Sinal mouse_exited do PauseButton conectado!")
	if not pause_button.button_down.is_connected(_on_pause_button_down):
		pause_button.button_down.connect(_on_pause_button_down)
		print("Sinal button_down do PauseButton conectado!")
	if not pause_button.button_up.is_connected(_on_pause_button_up):
		pause_button.button_up.connect(_on_pause_button_up)
		print("Sinal button_up do PauseButton conectado!")
		print("PauseButton configurado: visible = ", pause_button.visible, ", disabled = ", pause_button.disabled, ", z_index = ", pause_button.z_index, ", process_mode = ", pause_button.process_mode, ", global_rect = ", pause_button.get_global_rect())
	else:
		print("Erro: PauseButton não encontrado!")

	if pause_menu_node:
		if pause_menu_node is CanvasLayer:
			pause_menu_node.layer = 10
			pause_menu_node.process_mode = Node.PROCESS_MODE_ALWAYS
			print("PauseMenuNode configurado como CanvasLayer: layer = ", pause_menu_node.layer, ", process_mode = ", pause_menu_node.process_mode)
		else:
			print("ERRO: PauseMenuNode não é CanvasLayer, é ", pause_menu_node.get_class(), ". Converta para CanvasLayer no editor!")
	else:
		print("ERRO CRÍTICO: PauseMenuNode não encontrado em $UILayer/PauseMenuNode!")

	if pause_menu:
		pause_menu.visible = false
		pause_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		if not pause_menu.continue_pressed.is_connected(_on_continue_button_pressed):
			pause_menu.continue_pressed.connect(_on_continue_button_pressed)
			print("Sinal continue_pressed conectado ao PauseMenu!")
		# Removido a conexão ao exit_pressed
		print("PauseMenu configurado: tipo = ", pause_menu.get_class(), ", visible = ", pause_menu.visible, ", process_mode = ", pause_menu.process_mode)
	else:
		print("ERRO CRÍTICO: PauseMenu não encontrado em $UILayer/PauseMenuNode/PauseMenu!")

	var ui_layer = $UILayer
	if ui_layer:
		ui_layer.process_mode = Node.PROCESS_MODE_ALWAYS
		ui_layer.layer = 0
		print("UILayer configurado: process_mode = ", ui_layer.process_mode, ", layer = ", ui_layer.layer)
	else:
		print("Erro: UILayer não encontrado!")

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Input detectado (mouse), paused = ", get_tree().paused, ", position = ", event.global_position)
		if pause_button and pause_button.visible and not pause_button.disabled and pause_button.get_global_rect().has_point(event.global_position):
			print("Clique detectado no PauseButton!")
			_on_pause_button_pressed()
		if menu_button and menu_button.visible and not menu_button.disabled and menu_button.get_global_rect().has_point(event.global_position):
			print("Clique detectado no MenuButton!")
			_on_menu_button_pressed()
	if event is InputEventScreenTouch and event.pressed:
		print("Input detectado (toque), paused = ", get_tree().paused, ", position = ", event.position, ", PauseButton rect = ", pause_button.get_global_rect() if pause_button else "null", ", MenuButton rect = ", menu_button.get_global_rect() if menu_button else "null")
		if pause_button and pause_button.visible and not pause_button.disabled and pause_button.get_global_rect().has_point(event.position):
			print("Toque detectado no PauseButton!")
			_on_pause_button_pressed()
		if menu_button and menu_button.visible and not menu_button.disabled and menu_button.get_global_rect().has_point(event.position):
			print("Toque detectado no MenuButton!")
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
	
	if pause_container:
		pause_container.visible = true
		print("PauseMarginContainer visível após VAI! visible = ", pause_container.visible)
	else:
		print("Erro: PauseMarginContainer não encontrado ao iniciar jogo!")
	
	spawn_initial_food_pair()

func spawn_initial_food_pair():
	if not game_started:
		print("spawn_initial_food_pair bloqueado: game_started é false")
		return
	
	var spawner = $SpawnerComida
	if spawner:
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
	print("MenuButton pressionado! Mostrando Bio Fato. Posição do clique: ", get_global_mouse_position())
	get_tree().paused = false
	
	if $UILayer/GameOverLabel:
		$UILayer/GameOverLabel.visible = false
	if $UILayer/FinalScoreLabel:
		$UILayer/FinalScoreLabel.visible = false
	if $UILayer/MenuButton:
		$UILayer/MenuButton.visible = false
		$UILayer/MenuButton.set_process_input(false)
	
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 10
	add_child(canvas_layer)
	
	var bio_fato = bio_fato_scene.instantiate()
	if bio_fato:
		print("BioFato instanciado com sucesso!")
		canvas_layer.add_child(bio_fato)
		bio_fato.z_index = 100
	else:
		print("Erro: Falha ao instanciar bio_fato_scene!")
	
	await get_tree().process_frame
	
	if bio_fato and bio_fato.has_node("BioFato/BotaoContinuar"):
		var botao = bio_fato.get_node("BioFato/BotaoContinuar")
		botao.grab_focus()
		botao.mouse_filter = Control.MOUSE_FILTER_STOP
		print("Foco dado ao BotaoContinuar! Mouse Filter: ", botao.mouse_filter)
	else:
		print("Erro: BotaoContinuar não encontrado na hierarquia ou bio_fato é null!")

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
	if pause_container:
		pause_container.visible = false
		print("PauseMarginContainer escondido no reset: visible = ", pause_container.visible)
	if pause_menu:
		pause_menu.hide_menu()
		print("PauseMenu escondido no reset")
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
	
	if pause_container:
		pause_container.visible = false
		print("PauseMarginContainer escondido no Game Over: visible = ", pause_container.visible)
	
	if pause_menu:
		pause_menu.hide_menu()
		print("PauseMenu escondido no Game Over")
	
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
	
	if menu_button:
		await get_tree().process_frame
		menu_button.visible = true
		menu_button.disabled = false
		print("MenuButton ativado: position = ", menu_button.position, ", global_rect = ", menu_button.get_global_rect())
	else:
		print("Erro: MenuButton não encontrado!")
	
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
	@warning_ignore("integer_division")
	var new_threshold = int(new_score / 100) * 100
	if new_threshold > last_score_threshold:
		change_food_pair()
		last_score_threshold = new_threshold
		increase_fall_speed()
		increase_player_speed()
		decrease_spawn_wait()
		print("Novo par de alimentos gerado em ", new_score, " pontos!")

func _on_pause_button_pressed():
	if not game_started:
		print("Pause bloqueado: game_started é false")
		return
	if not pause_button:
		print("Erro: PauseButton não encontrado ao tentar pausar!")
		return
	if not pause_button.visible:
		print("Erro: PauseButton está invisível!")
		return
	if pause_button.disabled:
		print("Erro: PauseButton está desabilitado!")
		return
	print("PauseButton clicado! Estado do jogo: game_started = ", game_started, ", paused = ", get_tree().paused)
	get_tree().paused = true
	var spawn_timer = $SpawnerComida/SpawnTimer
	if spawn_timer:
		spawn_timer.paused = true
		print("SpawnTimer pausado explicitamente")
	else:
		print("Erro: SpawnTimer não encontrado!")
	if pause_container:
		pause_container.visible = false
		print("Jogo pausado: PauseMarginContainer escondido, visible = ", pause_container.visible)
	else:
		print("Erro: PauseMarginContainer não encontrado ao pausar!")
	if pause_menu:
		print("Tentando exibir PauseMenu: visibilidade atual = ", pause_menu.visible, ", process_mode = ", pause_menu.process_mode)
		pause_menu.show_menu()
		print("PauseMenu exibido, nova visibilidade = ", pause_menu.visible, ", process_mode = ", pause_menu.process_mode)
	else:
		print("ERRO CRÍTICO: PauseMenu não encontrado ao pausar!")
	# Animação de clique após a pausa
	if pause_button:
		print("Iniciando animação de clique no PauseButton. Escala inicial: ", pause_button.scale)
		var tween = create_tween()
		if tween:
			tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			tween.tween_property(pause_button, "scale", Vector2(1.2, 1.2), 0.15)  # Aumenta para 20% maior
			tween.tween_property(pause_button, "scale", Vector2(1.0, 1.0), 0.15)  # Volta ao normal
			tween.parallel().tween_property(pause_button, "modulate", Color(0.8, 0.8, 0.8), 0.15)  # Escurece um pouco
			tween.parallel().tween_property(pause_button, "modulate", Color(1.0, 1.0, 1.0), 0.15)  # Volta à cor original
			print("Animação de clique configurada com sucesso.")

func _on_pause_button_down():
	if pause_button and pause_button.visible and not pause_button.disabled:
		print("PauseButton pressionado! Iniciando efeito de pressionamento. Escala inicial: ", pause_button.scale)
		var tween = create_tween()
		if tween:
			tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
			tween.tween_property(pause_button, "scale", Vector2(0.9, 0.9), 0.1)  # Reduz 10% para simular pressão
			tween.parallel().tween_property(pause_button, "modulate", Color(0.7, 0.7, 0.7), 0.1)  # Escurece mais
			print("Efeito de pressionamento aplicado.")
	else:
		print("Erro: PauseButton não encontrado, invisível ou desabilitado ao pressionar!")

func _on_pause_button_up():
	if pause_button and pause_button.visible and not pause_button.disabled:
		print("PauseButton solto! Restaurando estado inicial. Escala atual: ", pause_button.scale)
		var tween = create_tween()
		if tween:
			tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
			tween.tween_property(pause_button, "scale", Vector2(1.0, 1.0), 0.1)  # Volta ao normal
			tween.parallel().tween_property(pause_button, "modulate", Color(1.0, 1.0, 1.0), 0.1)  # Volta à cor original
			print("Efeito de soltura aplicado.")
	else:
		print("Erro: PauseButton não encontrado, invisível ou desabilitado ao soltar!")

func _on_continue_button_pressed():
	print("SINAL RECEBIDO: ContinueButton pressionado no Main! Despausando jogo...")
	if not game_started:
		print("Continue bloqueado: game_started é false")
		return
	get_tree().paused = false
	if has_node("Player"):
		$Player.set_process(true)
		print("Player process ativado: ", $Player.is_processing())
	if $SpawnerComida and $SpawnerComida.has_node("SpawnTimer"):
		$SpawnerComida/SpawnTimer.paused = false
		if $SpawnerComida/SpawnTimer.is_stopped():
			$SpawnerComida/SpawnTimer.start()
			print("SpawnTimer reiniciado após despausar")
	if pause_container:
		pause_container.visible = true
		print("Jogo despausado: PauseMarginContainer visível, visible = ", pause_container.visible)
	else:
		print("Erro: PauseMarginContainer não encontrado ao despausar!")
	if pause_menu:
		pause_menu.hide_menu()
		print("PauseMenu escondido")
	else:
		print("Erro: PauseMenu não encontrado ao despausar!")
	if left_button and right_button:
		left_button.visible = true
		right_button.visible = true
		print("Botões de toque visíveis após despausar: left = ", left_button.visible, ", right = ", right_button.visible)
	if background_music and musica_ligada_original:
		if not background_music.playing:
			background_music.play()
			print("Música de fundo reiniciada após despausar")
	print("Jogo despausado com sucesso! paused = ", get_tree().paused)

# Removido _on_exit_button_pressed, pois o sinal exit_pressed foi eliminado

func _on_pause_button_mouse_entered():
	if pause_button and pause_button.visible and not pause_button.disabled:
		var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(pause_button, "modulate", Color(1.5, 1.5, 1.5), 0.2)  # Aumenta o brilho
		print("Mouse entrou no PauseButton: brilho aumentado para ", Color(1.5, 1.5, 1.5))
	else:
		print("Erro: PauseButton não encontrado, invisível ou desabilitado ao entrar mouse! visible = ", pause_button.visible if pause_button else "null", ", disabled = ", pause_button.disabled if pause_button else "null")

func _on_pause_button_mouse_exited():
	if pause_button and pause_button.visible and not pause_button.disabled:
		var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(pause_button, "modulate", Color(1.0, 1.0, 1.0), 0.2)  # Volta ao normal
		print("Mouse saiu do PauseButton: brilho restaurado para ", Color(1.0, 1.0, 1.0))
	else:
		print("Erro: PauseButton não encontrado, invisível ou desabilitado ao sair mouse! visible = ", pause_button.visible if pause_button else "null", ", disabled = ", pause_button.disabled if pause_button else "null")
