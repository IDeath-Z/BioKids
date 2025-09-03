extends Control

@onready var animacao_tela = $AnimacaoTela
var botao_pressionado = ""

func _on_mini_game_raio_x_pressed() -> void:
	animacao_tela.play("mover_cenario")
	botao_pressionado = "raioX"
	

func _on_botao_voltar_pressed() -> void:
	EstadoVariaveisGlobais.urso_saiu_tela_menu = true
	get_tree().change_scene_to_file("res://telas/interface/inicio/tela_inicial.tscn")


func _on_animacao_tela_animation_finished(anim_name: StringName) -> void:
	if anim_name == "mover_cenario":
		match botao_pressionado:
			"raioX":
				get_tree().change_scene_to_file("res://telas/minigames/raioX/raio_x_menu.tscn")
		
		
