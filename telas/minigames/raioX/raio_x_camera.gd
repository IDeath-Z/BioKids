extends Control

@onready var camera_display = $CameraDisplay
@onready var camera_container = $CameraDisplay/SubViewport
@onready var camera_view = $CameraDisplay/SubViewport/CameraView
@onready var timer = $ContaineBotaoScanner/Timer
@onready var scanner_button = $ContaineBotaoScanner/BotaoCliqueAqui

var android_camera: AndroidCamera

func _ready() -> void:
	
	if OS.get_name() == "Android":
		android_camera = AndroidCamera.new()

		if android_camera and android_camera.has_signal("camera_frame"):
			android_camera.camera_frame.connect(Callable(self, "_on_camera_frame"))
			android_camera.start_camera(camera_view.get_size().x, camera_view.get_size().y, false)

func _on_camera_frame(_timestamp: int, data: PackedByteArray, width: int, height: int) -> void:
	# Converte os bytes brutos em ImageTexture e atualiza a TextureRect
	var tex := AndroidCamera.raw_data_to_image(data, width, height)
	if camera_view:
		camera_view.texture = tex

func _on_start_capturing_pressed() -> void:
	if android_camera:
		android_camera.start_camera(camera_view.get_size().x, camera_view.get_size().y, false)

func _on_stop_capturing_pressed() -> void:
	if android_camera:
		android_camera.stop_camera()

func _on_botao_clique_aqui_pressed() -> void:
	timer.start()
	
func _on_timer_timeout() -> void:
	if OS.get_name() == "Android":
		_on_stop_capturing_pressed()
		get_tree().change_scene_to_file("res://telas/minigames/raioX/raio_x_imagem.tscn")
