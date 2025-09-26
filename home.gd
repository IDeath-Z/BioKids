extends Control


@onready var menu_botes_tela_principal = $MarginContainerPrincipal
@onready var botao_jogar = $MarginContainerPrincipal/GridBotoes/BotaoJogar

func _on_botao_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/interface/selecaoMiniGame/tela_selecao_mini_game.tscn")
	


func _on_botao_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/jogo_vacina/cenas/main.tscn")
