extends Control

@onready var player_de_audio = $AudioStreamPlayer

func _ready() -> void:
	player_de_audio.stream = preload("res://telas/minigames/jogo_vacina/sounds/bio_fato_vacina.mp3")
	player_de_audio.connect("finished", Callable(self, "_on_bio_fato_audio_finished"))
	
func _on_botao_continuar_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/interface/selecaoMiniGame/tela_selecao_mini_game.tscn")

func _on_bio_fato_botao_continuar_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/interface/selecaoMiniGame/tela_selecao_mini_game.tscn")

func _on_bio_fato_botao_audio_pressed() -> void:
	MusicPlayer.parar_para_evento_especial()
	player_de_audio.play()
	
func _on_bio_fato_audio_finished() -> void:
	MusicPlayer.restaurar_gerenciamento_automatico()
	
