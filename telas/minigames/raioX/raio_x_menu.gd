extends Control

@onready var tela_principal = $MainBackgroud
@onready var camera_view = $CameraDisplay/SubViewport/CameraView
@onready var camera_container = $CameraDisplay/SubViewport
@onready var camera_display = $CameraDisplay
@onready var container_botoes = $MarginContainer/GridBotoes
@onready var camera_button = $MarginContainer/GridBotoes/BotaoCamera
@onready var timer = $ContaineBotaoScanner/Timer
@onready var scanner_button = $ContaineBotaoScanner/BotaoScanner
@onready var x_ray_image = $TelaRaioX
@onready var animacao_tela = $AnimacaoTela

var android_camera: AndroidCamera

func _ready() -> void:
	
	android_camera = AndroidCamera.new()
	scanner_button.visible = false

	# Conecta o sinal que entrega frames brutos (timestamp, data, width, height)
	if android_camera and android_camera.has_signal("camera_frame"):
		android_camera.camera_frame.connect(Callable(self, "_on_camera_frame"))
		
		if camera_display:
			camera_display.visible = false

func _on_botao_camera_pressed() -> void:
	if OS.get_name() == "Android":
		_on_check_camera_permissions()
	elif OS.get_name() == "Windows":
		camera_view.texture = preload("res://assets/imagens/interface/x-ray.jpg")
		camera_display.visible = true

func _on_botao_como_jogar_pressed() -> void:
	pass # Replace with function body.

func _on_botao_voltar_pressed() -> void:
	animacao_tela.play("mover_cenario")

func _on_camera_frame(_timestamp: int, data: PackedByteArray, width: int, height: int) -> void:
	# Converte os bytes brutos em ImageTexture e atualiza a TextureRect
	var tex := AndroidCamera.raw_data_to_image(data, width, height)
	if camera_view:
		camera_view.texture = tex

func _on_check_camera_permissions() -> void:
	if not android_camera:
		return

	var granted := android_camera.request_camera_permissions()

	if granted:
		# inicia a câmera e mostra a view
		# Problema ta aqui, a view não ta com a tamanho, tendo que ficar fora da tela pra caber
		android_camera.start_camera(camera_view.get_size().x, camera_view.get_size().y, false)
		if camera_display:
			camera_display.visible = true
			scanner_button.text = "Escanear"
			scanner_button.visible = true
			container_botoes.visible = false
	else:
		pass

func _on_start_capturing_pressed() -> void:
	if android_camera:
		android_camera.start_camera(1920, 1080, false)
		if camera_display:
			camera_display.visible = true

func _on_stop_capturing_pressed() -> void:
	if android_camera:
		android_camera.stop_camera()
		if camera_display:
			camera_display.visible = false

func _on_botao_scan_pressed() -> void:
	scanner_button.visible = false

	if scanner_button.text == "OK":
		x_ray_image.visible = false
		container_botoes.visible = true
		return

	timer.start()

func _on_timer_timeout() -> void:
	if OS.get_name() == "Android":
		_on_stop_capturing_pressed()

	camera_display.visible = false

	x_ray_image.visible = true
	scanner_button.visible = true
	scanner_button.text = "OK"

func _on_animacao_tela_animation_finished(anim_name: StringName) -> void:
	if anim_name == "mover_cenario":
		get_tree().change_scene_to_file("res://telas/interface/selecaoMiniGame/tela_selecao_mini_game.tscn")
