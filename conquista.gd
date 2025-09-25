extends Node2D

@onready var animacao_urso = $animacao_urso
@onready var animacao_medalha = $medalha

func _ready():
	await get_tree().create_timer(1.5).timeout
	animacao_urso.play("urso_heroi") 
	
	await get_tree().create_timer(1.5).timeout
	animacao_medalha.play("medalha_conquista") 
	
	await animacao_urso.animation_finished
	animacao_urso.stop()
	
	await animacao_medalha.animation_finished
	animacao_medalha.stop()
	
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://telas/minigames/jogo_vacina/cenas/bio_fato_vacina.tscn")
