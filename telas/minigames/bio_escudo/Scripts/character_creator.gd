extends Control

func _on_botao_voltar_pressed() -> void:
	if MusicPlayer:
		# Garante que o gerenciamento automático volte e restaura o volume normal
		MusicPlayer.restaurar_gerenciamento_automatico()
		MusicPlayer.mudar_volume(1.0)
		
	get_tree().change_scene_to_file("res://telas/minigames/bio_escudo/Scenes/main.tscn")

@onready var tutorial = $CreatorScreen/TutorialPopup

func _ready():
	tutorial.show_message("Oi, amiguinho! Que bom te ver!\nVamos vestir o jaleco de doutor no Ursinho Amigo?")
	$Musica_fundo.play()
