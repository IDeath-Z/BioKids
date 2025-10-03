extends Control

@onready var som_button = $Som  # Referência ao botão som

func _ready():
	# Configura toggle som inicial (liga)
	AudioServer.set_bus_mute(0, false)  # Bus 0 é master

func _on_iniciar_pressed():
	get_tree().change_scene_to_file("res://telas/minigames/caca_bacterias/scenes/GameScene.tscn")  # Muda para cena do jogo (crie depois)

func _on_como_jogar_pressed():
	get_tree().change_scene_to_file("res://telas/minigames/caca_bacterias/scenes/HowToPlay.tscn")  # Muda para tela como jogar

func _on_sair_pressed():
	# Transição direta para a tela de minigames
	get_tree().change_scene_to_file("res://telas/interface/selecaoMiniGame/tela_selecao_mini_game.tscn")  # Ajuste o caminho conforme necessário
