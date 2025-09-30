extends CanvasLayer


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/bio_escudo/Scenes/Character_Creator.tscn")


func _on_info_button_pressed() -> void:
	pass # Replace with function body.


func _on_voltar_button_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/interface/selecaoMiniGame/tela_selecao_mini_game.tscn")
