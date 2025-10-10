extends Control

#@onready var menu_botes_tela_principal = $MarginContainerPrincipal
@onready var botao_iniciar = $MarginContainerPrincipal2/GridBotoes/BotaoIniciar
#@onready var botao_como_jogar = $MarginContainerPrincipal2/GridBotoes/BotaoComoJogar
@onready var botao_voltar = $MarginContainerPrincipal2/GridBotoes/BotaoVoltar
@onready var tela_01 = $Tela_01
@onready var box_botoes = $MarginContainerPrincipal2
@onready var textura_balao = $TexturaUrso/TexturaBalao
@onready var animacao_balao = $TexturaUrso/TexturaBalao/AnimacaoBalao
@onready var textura_urso = $TexturaUrso
@onready var animacao_urso = $TexturaUrso/AnimacaoUrso
@onready var logo = $Logo_jogo_vacina
@onready var animacao_botao = $MarginContainerPrincipal2/GridBotoes/AnimacaoBotao

var animacao_reversa: bool

func _ready() -> void:
	textura_balao.visible = false
	textura_urso.visible = false
	

func _on_botao_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/interface/selecaoMiniGame/tela_selecao_mini_game.tscn")
	

func _on_botao_iniciar_pressed() -> void:
	animacao_botao.play("fade")
	textura_balao.visible = true
	textura_urso.visible = true
	animacao_urso.play("entrar_tela")
	animacao_balao.play("fade")
	
	await get_tree().create_timer(8.0).timeout
	
	get_tree().change_scene_to_file("res://telas/minigames/jogo_vacina/cenas/main.tscn")
	

#func _on_animacao_urso_animation_finished(anim_name: StringName) -> void:
	#animacao_balao.play("fade")
