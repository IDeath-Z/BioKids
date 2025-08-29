extends Control

func _on_botao_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/telas/selecaoMiniGame/tela_selecao_mini_game.tscn")
	
func _on_botao_opcoes_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/telas/opcoes/tela_opcoes.tscn")

func _on_botao_sair_pressed() -> void:
	get_tree().quit()
