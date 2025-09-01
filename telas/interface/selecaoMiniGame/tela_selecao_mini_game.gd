extends Control

func _on_mini_game_raio_x_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/raioX/raio_x_menu.tscn")

func _on_botao_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/interface/inicio/tela_inicial.tscn")
