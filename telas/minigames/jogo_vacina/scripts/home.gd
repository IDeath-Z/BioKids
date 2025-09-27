extends Control


@onready var menu_botes_tela_principal = $MarginContainerPrincipal
@onready var botao_iniciar = $MarginContainerPrincipal/GridBotoes/BotaoIniciar
@onready var botao_como_jogar = $MarginContainerPrincipal2/GridBotoes/BotaoComoJogar
@onready var botao_voltar = $MarginContainerPrincipal2/GridBotoes/BotaoVoltar


func _on_botao_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/interface/selecaoMiniGame/tela_selecao_mini_game.tscn")
	
func _on_botao_como_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/jogo_vacina/cenas/main.tscn")

func _on_botao_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/jogo_vacina/cenas/main.tscn")
