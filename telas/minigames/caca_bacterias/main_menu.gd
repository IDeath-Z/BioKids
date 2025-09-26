extends Control

@onready var som_button = $Som  # Referência ao botão som

func _ready():
	# Configura toggle som inicial (liga)
	AudioServer.set_bus_mute(0, false)  # Bus 0 é master

func _on_iniciar_pressed():
	get_tree().change_scene_to_file("res://telas/minigames/caca_bacterias/scenes/GameScene.tscn")  # Muda para cena do jogo (crie depois)

func _on_como_jogar_pressed():
	get_tree().change_scene_to_file("res://telas/minigames/caca_bacterias/scenes/HowToPlay.tscn")  # Muda para tela como jogar

func _on_som_pressed():
	var is_muted = AudioServer.is_bus_mute(0)
	AudioServer.set_bus_mute(0, not is_muted)
	som_button.text = "🔊 Som (" + ("Desligado" if not is_muted else "Ligado") + ")"
