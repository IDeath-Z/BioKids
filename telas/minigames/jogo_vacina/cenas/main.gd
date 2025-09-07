extends Node2D

# dicionário com as cenas que podem ser carregadas
var scenes = {
	"seringa": preload("res://telas/minigames/jogo_vacina/cenas/main.tscn"),
	"conquista":preload("res://telas/minigames/jogo_vacina/cenas/conquista.tscn")
}

# cena atual
var current_scene: Node = null

func _ready():
	# aqui você escolhe qual cena vem primeiro
	change_scene("seringa")

func change_scene(scene_name: String):
	if current_scene:
		current_scene.queue_free()  # remove a cena atual
	if scenes.has(scene_name):
		current_scene = scenes[scene_name].instantiate()
		$Placeholder.add_child(current_scene)
	else:
		push_error("Cena '%s' não encontrada!" % scene_name)
