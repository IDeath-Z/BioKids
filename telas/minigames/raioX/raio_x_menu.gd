extends Control

@onready var menu_botes_tela_principal = $MarginContainerPrincipal
@onready var botao_como_jogar = $MarginContainerPrincipal/GridBotoes/BotaoComoJogar
@onready var animacao_tela = $AnimacaoTela
@onready var android_camera = AndroidCamera.new()
@onready var menu_botoes_selecao = $MarginContainerSelecaoTipo
@onready var textura_urso = $TexturaUrso
@onready var animacao_urso = $TexturaUrso/AnimacaoUrso
@onready var textura_balao_fala = $TexturaBalao
@onready var animacao_balao = $TexturaBalao/AnimacaoBalao

func _ready() -> void:
	menu_botoes_selecao.visible = false
	textura_urso.visible = false
	textura_balao_fala.visible = false
	animacao_urso.play("entrar_tela")

func _on_botao_iniciar_pressed() -> void:
	if OS.get_name() == "Android":
		_on_check_camera_permissions()
	else:
		menu_botoes_selecao.visible = true
		menu_botes_tela_principal.visible = false

func _on_botao_como_jogar_pressed() -> void:
	animacao_urso.play("como_jogar")
	botao_como_jogar.disabled = true

func _on_botao_voltar_pressed() -> void:
	animacao_tela.play("mover_cenario")
	
func _on_botao_mao_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/raioX/mao/raio_x_camera_mao.tscn")

func _on_botao_pe_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/raioX/pe/raio_x_camera_pe.tscn")

func _on_botao_voltar_menu_bio_x_pressed() -> void:
	menu_botoes_selecao.visible = false
	menu_botes_tela_principal.visible = true

func _on_check_camera_permissions() -> void:
	if not android_camera:
		return

	var granted := android_camera.request_camera_permissions()
	if granted:
		menu_botoes_selecao.visible = true
		menu_botes_tela_principal.visible = false
	else:
		pass

func _on_animacao_tela_animation_finished(anim_name: StringName) -> void:
	if anim_name == "mover_cenario":
		get_tree().change_scene_to_file("res://telas/interface/selecaoMiniGame/tela_selecao_mini_game.tscn")

func _on_animacao_urso_animation_started(anim_name: StringName) -> void:
	if anim_name == "entrar_tela":
		await get_tree().create_timer(0.1).timeout
		textura_urso.visible = true

func _on_animacao_urso_animation_finished(anim_name: StringName) -> void:
		if anim_name == "como_jogar":
			textura_balao_fala.visible = true
			animacao_balao.play("fade")
