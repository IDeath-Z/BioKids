extends Node2D

var scenes = {
	"seringa": preload("res://telas/minigames/jogo_vacina/cenas/seringa.tscn"),
	"conquista":preload("res://telas/minigames/jogo_vacina/cenas/Conquista_01.tscn")
}

var current_scene: Node = null

func _ready():
	
	change_scene("seringa")
	ajustar_escala_telas()
	
	if get_viewport():
		get_viewport().connect("size_changed", Callable(self, "_on_viewport_resized"))
		connect("child_entered_tree", Callable(self, "_on_child_entered_tree"))
		
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

const BASE_SIZE := Vector2(720, 1080)

func ajustar_escala_telas():
	var screen_size = get_viewport_rect().size
	var scale_factor = min(screen_size.x / BASE_SIZE.x, screen_size.y / BASE_SIZE.y)
	# centraliza e escala todas as telas (Controls) dentro da Main
	for child in get_children():
		if child is Control:
			child.scale = Vector2(scale_factor, scale_factor)
			var scaled_size = BASE_SIZE * scale_factor
			child.position = (screen_size - scaled_size) / 2
			
func _on_viewport_resized():
	ajustar_escala_telas()

	
