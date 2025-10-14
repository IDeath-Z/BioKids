extends CanvasLayer

func parar_para_evento_especial():
	MusicPlayer.parar_para_evento_especial()

func _on_botao_iniciar_pressed() -> void:
	MusicPlayer.parar_para_evento_especial()
	get_tree().change_scene_to_file("res://telas/minigames/bio_escudo/Scenes/Character_Creator.tscn")
	
func _on_botao_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/interface/selecaoMiniGame/tela_selecao_mini_game.tscn")
