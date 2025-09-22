extends Control

@onready var camera_view = $CameraDisplay/SubViewport/CameraView
@onready var cor_fundo = $Fundo
@onready var animacao_fundo = $Fundo/AnimacaoFundo
@onready var animacar_texto = $AspectRatioContainerDicas/PopUpDicas/Label/AnimacaoTexto
@onready var touch_button = $TouchScreen
@onready var animacao_scanner = $Scanner/AnimacaoScanner
@onready var mao_click = $MaoClick
@onready var timer_mao = $TimerMao

var android_camera: AndroidCamera
var toque_na_tela = false

func _ready() -> void:
	timer_mao.start()
	mao_click.hide()
	
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

func _on_touch_screen_pressed() -> void:
	toque_na_tela = true
	animacao_fundo.play("fade")
	animacao_scanner.play("mover")
	animacar_texto.play("remover_linha")
	touch_button.disabled = true
	mao_click.hide()
	mao_click.stop()
	
func _on_timer_mao_timeout() -> void:
	if !toque_na_tela:
		mao_click.show()
		mao_click.play("click")

func _on_animacao_scanner_animation_finished(anim_name: StringName) -> void:
	if anim_name == "mover":
		animacar_texto.play("fade")
		animacao_fundo.play("cobrir")
		
func _on_animacao_fundo_animation_finished(anim_name: StringName) -> void:
	if anim_name == "cobrir":
		get_tree().change_scene_to_file("res://telas/minigames/raioX/pe/raio_x_imagem_pe.tscn")
