extends Control

@onready var area_mao = $AreaMao
@onready var animacao_mao = $AreaMao/AnimacaoMao
@onready var texto = $AspectRatioContainerDicas/PopUpDicas/Label
@onready var animacao_texto = $AspectRatioContainerDicas/PopUpDicas/Label/AnimacaoTexto
@onready var botoes = $HBoxContainer
@onready var animacao_botoes = $HBoxContainer/AnimacaoBotoes

func _ready() -> void:
	area_mao.visible = false
	texto.visible = false
	botoes.visible = false
	animacao_mao.play("fade")
	animacao_texto.play("fade")
	animacao_botoes.play("fade")

func _on_botao_sim_pressed() -> void:
	pass # Fazer a logica pra ir pra tela de raio-x  de novo
	
func _on_botao_nao_pressed() -> void:
	# Colocar a tela do biofato
	get_tree().change_scene_to_file("res://telas/minigames/raioX/raio_x_menu.tscn")


func _on_animacao_mao_animation_started(anim_name: StringName) -> void:
	if anim_name == "fade":
		await get_tree().create_timer(0.1).timeout
		area_mao.visible = true
		texto.visible = true
		botoes.visible = true
