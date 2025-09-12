extends Control

func _on_botao_sim_pressed() -> void:
	pass # Fazer a logica pra ir pra tela de raio-x  de novo
	
func _on_botao_nao_pressed() -> void:
	# Colocar a tela do biofato
	get_tree().change_scene_to_file("res://telas/minigames/raioX/raio_x_menu.tscn")
