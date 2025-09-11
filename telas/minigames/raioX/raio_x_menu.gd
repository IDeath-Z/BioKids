extends Control

@onready var tela_principal = $MainBackgroud
@onready var container_botoes = $MarginContainer/GridBotoes
@onready var camera_button = $MarginContainer/GridBotoes/BotaoCamera
@onready var animacao_tela = $AnimacaoTela
@onready var android_camera = AndroidCamera.new()

func _on_botao_camera_pressed() -> void:
	if OS.get_name() == "Android":
		_on_check_camera_permissions()

func _on_botao_como_jogar_pressed() -> void:
	pass # Replace with function body.

func _on_botao_voltar_pressed() -> void:
	animacao_tela.play("mover_cenario")

func _on_check_camera_permissions() -> void:
	if not android_camera:
		return

	var granted := android_camera.request_camera_permissions()
	if granted:
		get_tree().change_scene_to_file("res://telas/minigames/raioX/raio_x_camera.tscn")
	else:
		pass

func _on_animacao_tela_animation_finished(anim_name: StringName) -> void:
	if anim_name == "mover_cenario":
		get_tree().change_scene_to_file("res://telas/interface/selecaoMiniGame/tela_selecao_mini_game.tscn")
