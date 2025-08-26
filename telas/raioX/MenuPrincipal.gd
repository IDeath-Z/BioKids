extends Control

@onready var titulo_principal = $MainBackgroud/TextTitulo
@onready var tela_principal = $MainBackgroud
@onready var text_scanner = $TextScanner
@onready var camera_view = $CameraDisplay/SubViewport/CameraView
@onready var camera_container = $CameraDisplay/SubViewport
@onready var camera_display = $CameraDisplay
@onready var container_botoes = $BotoesContainer
@onready var camera_button = $BotoesContainer/BotaoCamera
@onready var timer = $ContaineBotaoScanner/Timer
@onready var scanner_button = $ContaineBotaoScanner/BotaoScanner
@onready var x_ray_image = $FotoRaioX
@onready var tamanho_da_tela = get_window().size

var android_camera: AndroidCamera

func _ready() -> void:
	
	android_camera = AndroidCamera.new()
	scanner_button.visible = false
	text_scanner.visible = false

	# Conecta o sinal que entrega frames brutos (timestamp, data, width, height)
	if android_camera and android_camera.has_signal("camera_frame"):
		android_camera.camera_frame.connect(Callable(self, "_on_camera_frame"))
		
		if camera_display:
			camera_display.visible = false

func _init_variables() -> void:
	tela_principal.size.x = tamanho_da_tela.x
	tela_principal.size.y = tamanho_da_tela.y
	x_ray_image.size.x = tamanho_da_tela.x
	x_ray_image.size.y = tamanho_da_tela.y

func _on_botao_camera_pressed() -> void:

	print("Botao camera pressionado. OS=", OS.get_name())
	if OS.get_name() == "Android":
		titulo_principal.text = "Rodando no Android"
		_on_check_camera_permissions()
	elif OS.get_name() == "Windows":
		titulo_principal.text = "Rodando no Windows"
		camera_view.texture = preload("res://assets/x-ray.jpg")
		camera_display.visible = true
	elif OS.get_name() == "iOS":
		titulo_principal.text = "Rodando no iOS"
	else:
		titulo_principal.text = "Outro sistema: " + OS.get_name()

func _on_botao_opcoes_pressed() -> void:
	_on_botao_scan_pressed()

func _on_botao_sair_pressed() -> void:
	titulo_principal.text = "O tamanho da janela é: " + str(tamanho_da_tela)

func _on_camera_frame(_timestamp: int, data: PackedByteArray, width: int, height: int) -> void:
	# Converte os bytes brutos em ImageTexture e atualiza a TextureRect
	var tex := AndroidCamera.raw_data_to_image(data, width, height)
	if camera_view:
		camera_view.texture = tex

func _on_check_camera_permissions() -> void:

	if not android_camera:
		print("android_camera não inicializado")
		return

	var granted := android_camera.request_camera_permissions()
	print("request_camera_permissions returned:", granted)

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
		print("Permissão ainda não concedida — aguarde o usuário e tente novamente")

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

	text_scanner.visible = true
	text_scanner.text = "Escaneando..."
	timer.start()

func _on_timer_timeout() -> void:

	if OS.get_name() == "Android":
		_on_stop_capturing_pressed()

	camera_display.visible = false
	text_scanner.visible = false

	x_ray_image.visible = true
	scanner_button.visible = true
	scanner_button.text = "OK"
