extends Control

func _on_botao_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/telas/inicio/tela_inicial.tscn")
