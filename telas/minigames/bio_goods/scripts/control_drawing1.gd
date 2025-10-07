extends Control

# === HISTÓRICO DE AÇÕES (UNDO) ===
var undo_stack: Array = []
var max_history: int = 10  # máximo de passos que podem ser desfeitos

# === VARIÁVEIS DE DESENHO ===
var draw_mode: String = "balde"
var draw_color: Color = Color(1, 0, 0)
var brush_size: int = 8
var erasing: bool = false

@onready var color_layer: TextureRect = $ColorLayer
@onready var desenho_node: TextureRect = $Desenho

@export var color_popup_path: NodePath  # Popup de tintas coloridas
var color_popup: PopupPanel

var img: Image
var tex: ImageTexture
var desenho_img: Image


# === READY ===
func _ready():
	color_popup = get_node_or_null(color_popup_path)
	if color_popup:
		color_popup.color_chosen.connect(_on_color_chosen)

	# Inicializa área de desenho
	color_layer.size = desenho_node.size
	var w = max(1, int(color_layer.size.x))
	var h = max(1, int(color_layer.size.y))

	img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	tex = ImageTexture.create_from_image(img)
	color_layer.texture = tex

	var desenho_tex: Texture2D = desenho_node.texture
	desenho_img = desenho_tex.get_image()


# === ENTRADAS DO USUÁRIO ===
func _input(event):
	if event is InputEventMouseButton:
		var local := color_layer.get_local_mouse_position()
		var inside := Rect2(Vector2.ZERO, color_layer.size).has_point(local)
		if not inside:
			return

		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				match draw_mode:
					"balde":
						_save_undo_state()
						_flood_fill(local, draw_color)
						tex.update(img)

					"borracha":
						_save_undo_state()
						erasing = true
						_erase_point(local)
						tex.update(img)
			else:
				erasing = false

	elif event is InputEventMouseMotion and erasing:
		var local := color_layer.get_local_mouse_position()
		_erase_point(local)
		tex.update(img)


# === BORRACHA ===
func _erase_point(pos: Vector2):
	var radius := brush_size
	for x in range(-radius, radius):
		for y in range(-radius, radius):
			var p := Vector2i(pos.x + x, pos.y + y)
			if p.x >= 0 and p.y >= 0 and p.x < img.get_width() and p.y < img.get_height():
				if Vector2(x, y).length() <= radius:
					img.set_pixelv(p, Color(0, 0, 0, 0))


# === SALVAR ESTADO PARA UNDO ===
func _save_undo_state():
	var snapshot := tex.get_image()
	if not undo_stack.is_empty():
		var last: Image = undo_stack.back()
		if snapshot.get_data() == last.get_data():
			return
	undo_stack.append(snapshot)
	if undo_stack.size() > max_history:
		undo_stack.pop_front()
	print("Estado salvo! Total de passos:", undo_stack.size())


# === VOLTAR UM PASSO ===
func _on_voltar_um_passo_pressed():
	if undo_stack.is_empty():
		print("Nada para desfazer.")
		return
	var snapshot: Image = undo_stack.pop_back()
	img = snapshot.duplicate()
	tex = ImageTexture.create_from_image(img)
	color_layer.texture = tex
	color_layer.queue_redraw()
	print("(" + str(undo_stack.size()) + ") Passo desfeito!")


# === BALDE (FILL) ===
func _flood_fill(start: Vector2, new_color: Color):
	_save_undo_state()
	var s = Vector2i(start)
	if s.x < 0 or s.y < 0 or s.x >= img.get_width() or s.y >= img.get_height():
		return

	var target = img.get_pixelv(s)
	var tolerance := 0.08
	if _color_close(target, new_color, tolerance):
		return

	var stack: Array[Vector2i] = [s]
	var visited := {}
	while stack.size() > 0:
		var p = stack.pop_back()
		if p in visited:
			continue
		visited[p] = true

		if p.x < 0 or p.y < 0 or p.x >= img.get_width() or p.y >= img.get_height():
			continue

		var desen_px = int(float(p.x) / img.get_width() * desenho_img.get_width())
		var desen_py = int(float(p.y) / img.get_height() * desenho_img.get_height())
		var line_color = desenho_img.get_pixel(desen_px, desen_py)
		var brightness = (line_color.r + line_color.g + line_color.b) / 3.0
		if brightness < 0.25:
			continue

		var current = img.get_pixelv(p)
		if not _color_close(current, target, tolerance):
			continue

		img.set_pixelv(p, new_color)
		stack.append(Vector2i(p.x+1, p.y))
		stack.append(Vector2i(p.x-1, p.y))
		stack.append(Vector2i(p.x, p.y+1))
		stack.append(Vector2i(p.x, p.y-1))

	tex.update(img)
	img = tex.get_image()


# === COMPARAÇÃO DE CORES ===
func _color_close(a: Color, b: Color, tol: float) -> bool:
	var dr = abs(a.r - b.r)
	var dg = abs(a.g - b.g)
	var db = abs(a.b - b.b)
	var da = abs(a.a - b.a)
	return max(dr, dg, db, da) <= tol


# === BOTÕES ===
func _on_pincel_pressed():
	_on_voltar_um_passo_pressed()

func _on_borracha_pressed():
	draw_mode = "borracha"
	print("Modo borracha ativado!")

func _on_balde_pressed():
	draw_mode = "balde"

func _on_colorpicker_pressed():
	if color_popup:
		color_popup.popup_centered()
		print("Popup aberto!")  # debug opcional


func _on_color_chosen(color: Color):
	draw_color = color
	print("Cor escolhida:", color)

func _on_voltar_selecao_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/bio_goods/scene/selecionar_quadro.tscn")

func _on_apagar_tudo_pressed():
	_save_undo_state()
	img.fill(Color(0, 0, 0, 0))
	tex.update(img)
	print("Tudo apagado!")





func _on_color_icon_tx_t_button_pressed() -> void:
	if color_popup:
		color_popup.popup_centered()
		print("Popup aberto!")  # debug opcional
