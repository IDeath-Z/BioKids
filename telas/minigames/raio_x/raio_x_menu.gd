extends Control

@onready var menu_botes_tela_principal = $MarginContainerPrincipal
@onready var animacao_tela = $AnimacaoTela
@onready var android_camera = AndroidCamera.new()
@onready var menu_botoes_selecao = $MarginContainerSelecaoTipo
@onready var textura_urso = $TexturaUrso
@onready var animacao_urso = $TexturaUrso/AnimacaoUrso
@onready var textura_balao_fala = $TexturaBalao
@onready var animacao_balao = $TexturaBalao/AnimacaoBalao

var animacao_reversa: bool

func _ready() -> void:
	menu_botoes_selecao.visible = false
	textura_urso.visible = false
	textura_balao_fala.visible = false
	animacao_urso.play("entrar_tela")

func _on_botao_iniciar_pressed() -> void:
	if OS.get_name() == "Android":
		_on_check_camera_permissions()
	else:
		animacao_reversa = false
		animacao_urso.play("como_jogar")
		menu_botoes_selecao.visible = true
		menu_botes_tela_principal.visible = false

func _on_botao_voltar_pressed() -> void:
	animacao_tela.play("mover_cenario")
	
func _on_botao_mao_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/raio_x/mao/raio_x_camera_mao.tscn")

func _on_botao_pe_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/raio_x/pe/raio_x_camera_pe.tscn")

func _on_botao_voltar_menu_bio_x_pressed() -> void:
	animacao_reversa = true
	animacao_urso.play_backwards("como_jogar")
	menu_botoes_selecao.visible = false
	menu_botes_tela_principal.visible = true

func _on_check_camera_permissions() -> void:
	if not android_camera:
		return

	var granted := android_camera.request_camera_permissions()
	if granted:
		animacao_reversa = false
		animacao_urso.play("como_jogar")
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
	if anim_name == "como_jogar":
		if animacao_reversa:
			animacao_balao.speed_scale = 4.0
			animacao_balao.play_backwards("fade")

func _on_animacao_urso_animation_finished(anim_name: StringName) -> void:
		if anim_name == "como_jogar":
			if !animacao_reversa:
				animacao_balao.speed_scale = 1.0
				textura_balao_fala.visible = true
				animacao_balao.play("fade")
