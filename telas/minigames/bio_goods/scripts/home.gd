extends Control

func _ready() -> void:
	pass # Pode deixar vazio ou inicializar algo aqui.

func _process(delta: float) -> void:
	pass # Só use se precisar rodar algo a cada frame.

func _on_iniciar_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/bio_goods/scene/selecionar_quadro.tscn")

func _on_sair_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/interface/selecaoMiniGame/tela_selecao_mini_game.tscn")
