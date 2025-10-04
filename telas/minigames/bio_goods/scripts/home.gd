extends Control

func _on_iniciar_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/bio_goods/scene/selecionar_quadro.tscn")

func _on_como_jogar_pressed() -> void:
	pass # Replace with function body.

func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/interface/selecaoMiniGame/tela_selecao_mini_game.tscn")
