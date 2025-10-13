extends Control

@onready var fala_urso = $AudioStreamPlayer

func _on_botao_continuar_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/interface/selecaoMiniGame/tela_selecao_mini_game.tscn")

func _on_bio_fato_botao_continuar_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/interface/selecaoMiniGame/tela_selecao_mini_game.tscn")

func _on_botao_audio_pressed() -> void:
	fala_urso.play()


func _on_bio_fato_botao_audio_pressed() -> void:
	fala_urso.play()
