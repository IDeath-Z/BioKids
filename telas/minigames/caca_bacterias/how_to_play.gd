extends Control

func _on_voltar_pressed():
	get_tree().change_scene_to_file("res://telas/minigames/caca_bacterias/scenes/main_menu.tscn")


func _on_iniciar_jogo_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/caca_bacterias/scenes/GameScene.tscn")
