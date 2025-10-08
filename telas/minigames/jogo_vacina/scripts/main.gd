extends Node2D


var scenes = {
	"seringa": "res://telas/minigames/jogo_vacina/cenas/seringa.tscn",
	"conquista": "res://telas/minigames/jogo_vacina/cenas/Conquista_01.tscn"
}

var current_scene: Node = null

func _ready():
	ajustar_escala(get_viewport_rect().size)
	change_scene("seringa")
	
	if get_viewport():
		get_viewport().connect("size_changed", Callable(self, "_on_viewport_resized"))
		connect("child_entered_tree", Callable(self, "_on_child_entered_tree"))
		
func change_scene(scene_name: String):
	if current_scene:
		current_scene.queue_free()
		
	if scenes.has(scene_name):
		current_scene = load(scenes[scene_name]).instantiate()
		add_child(current_scene)
		if current_scene.has_signal("botao_voltar_pressed"):
			current_scene.botao_voltar_pressed.connect(voltar_home)
		if current_scene.has_node("local_vacina"):
			current_scene.get_node("local_vacina").connect("conquista_feita", Callable(self, "_on_conquista_feita"))
	else:
		push_error("Cena '%s' não encontrada!" % scene_name)
		
func _on_conquista_feita():
	get_tree().change_scene_to_file("res://telas/minigames/jogo_vacina/cenas/Conquista_01.tscn")
	
func voltar_home():
	get_tree().change_scene_to_file("res://telas/minigames/jogo_vacina/cenas/home.tscn")


# resolução base que você usou para montar o layout no editor
const BASE_SIZE := Vector2(720, 1080)

func ajustar_escala(screen_size: Vector2):
	# calcula o fator de escala proporcional à altura
	var scale_factor = screen_size.y / BASE_SIZE.y
	scale = Vector2(scale_factor, scale_factor)
	var parent = get_parent()
	if parent is Control:
		var parent_size = parent.get_rect().size
		position = (parent_size - BASE_SIZE * scale_factor) / 2
		for child in get_children():
			ajustar_no(child, scale_factor)


func ajustar_no(node, scale_factor):
	if node is Node2D:
		node.scale = Vector2(scale_factor, scale_factor)
	elif node is Control:
			node.scale = Vector2(scale_factor, scale_factor)
			node.custom_minimum_size *= scale_factor
			for child in node.get_children():
				ajustar_no(child, scale_factor)


# esse trecho faz o reajuste automático se a janela for redimensionada
func _notification(what):
	if what == Node.NOTIFICATION_WM_SIZE_CHANGED:
		ajustar_escala(get_viewport_rect().size)


func _on_botao_voltar_pressed():
	get_tree().change_scene_to_file("res://telas/interface/inicio/tela_inicial.tscn")
