extends Control

@onready var animacao_logo = $TexturaLogo/AnimacaoLogo
@onready var animacao_urso = $TexturaUrso/AnimacaoUrso
@onready var textura_logo = $TexturaLogo
@onready var textura_urso = $TexturaUrso
var botao_pressionado = ""

func _ready() -> void:
	if EstadoVariaveisGlobais.urso_saiu_tela_menu == true:
		EstadoVariaveisGlobais.urso_saiu_tela_menu = false
		textura_logo.visible = false
		textura_urso.visible = false
		animacao_logo.play_backwards("fade_out")
		animacao_urso.play_backwards("sair_tela")

func animacao() -> void:
	if EstadoVariaveisGlobais.urso_saiu_tela_menu == false:
		animacao_logo.play("fade_out")
		animacao_urso.play("sair_tela")
		
func _on_animacao_urso_animation_started(anim_name: StringName) -> void:
	await get_tree().create_timer(0.1).timeout
	textura_logo.visible = true
	textura_urso.visible = true
	
func _on_animacao_urso_animation_finished(anim_name: StringName) -> void:
	if anim_name == "sair_tela":
		match botao_pressionado:
			"jogar":
				get_tree().change_scene_to_file("res://telas/interface/selecaoMiniGame/tela_selecao_mini_game.tscn")
			"opcoes":
				get_tree().change_scene_to_file("res://telas/interface/opcoes/tela_opcoes.tscn")

func _on_botao_jogar_pressed() -> void:
	botao_pressionado = "jogar"
	animacao()
	
func _on_botao_opcoes_pressed() -> void:
	botao_pressionado = "opcoes"
	animacao()

func _on_botao_sair_pressed() -> void:
	get_tree().quit()
