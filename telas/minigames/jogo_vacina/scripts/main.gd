extends Node2D

# dicionário com as cenas que podem ser carregadas
var scenes = {
	"seringa": preload("res://telas/minigames/jogo_vacina/cenas/seringa.tscn"),
	"conquista":preload("res://telas/minigames/jogo_vacina/cenas/Conquista_01.tscn")
}

# cena atual
var current_scene: Node = null

func _ready():
	# aqui você escolhe qual cena vem primeiro
	change_scene("seringa")
	
func change_scene(scene_name: String):
	if current_scene:
		current_scene.queue_free()
		
	if scenes.has(scene_name):
		current_scene = scenes[scene_name].instantiate()
		add_child(current_scene)
		
		if current_scene.has_node("local_vacina"):
			current_scene.get_node("local_vacina").connect("conquista_feita", Callable(self, "_on_conquista_feita"))
		
	else:
		push_error("Cena '%s' não encontrada!" % scene_name)
		
func _on_conquista_feita():
	get_tree().change_scene_to_file("res://telas/minigames/jogo_vacina/cenas/Conquista_01.tscn")
