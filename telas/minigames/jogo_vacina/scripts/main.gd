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
	
	ajustar_escala_telas()
	
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


# resolução base (a que você usou pra desenvolver o layout)
const BASE_SIZE := Vector2(720, 1080)

func ajustar_escala_telas():
	# tamanho real da tela do dispositivo
	var screen_size = get_viewport_rect().size
	# calcula o fator de escala proporcional
	var scale_factor = screen_size.y / BASE_SIZE.y 
	# percorre todas as telas instanciadas dentro da Main
	for child in get_children():
		# aplica a escala apenas nos nós do tipo Control (telas)
		if child is Control:
			child.scale = Vector2(scale_factor, scale_factor)
	
