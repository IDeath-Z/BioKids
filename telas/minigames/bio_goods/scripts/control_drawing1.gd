extends Control

var draw_mode: String = "pincel"
var draw_color: Color = Color(1, 0, 0)
var brush_size: int = 8

@onready var color_layer: TextureRect = $ColorLayer
@onready var desenho_node: TextureRect = $Desenho

@export var picker_path: NodePath
@export var picker_icon_path: NodePath

var picker: ColorPickerButton
var picker_icon: TextureButton

var img: Image
var tex: ImageTexture
var desenho_img: Image


func _ready():
	picker = get_node_or_null(picker_path) as ColorPickerButton
	picker_icon = get_node_or_null(picker_icon_path) as TextureButton

	if picker:
		picker.color_changed.connect(_on_color_picker_color_changed)

		# pega o ColorPicker interno do botão e simplifica
		var cp: ColorPicker = picker.get_picker()
		cp.edit_alpha = false       # sem transparência
		cp.sliders_visible = false  # esconde sliders RGB
		cp.presets_visible = false  # esconde cores recentes
		cp.deferred_mode = true     # só aplica cor quando solta o mouse

	if picker_icon:
		picker_icon.pressed.connect(_on_texture_button_pressed)

	# inicializa área de desenho
	color_layer.size = desenho_node.size
	var w = max(1, int(color_layer.size.x))
	var h = max(1, int(color_layer.size.y))

	img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	tex = ImageTexture.create_from_image(img)
	color_layer.texture = tex

	var desenho_tex: Texture2D = desenho_node.texture
	desenho_img = desenho_tex.get_image()


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var pos = event.position - color_layer.global_position
		match draw_mode:
			"pincel":
				_draw_brush(pos, draw_color)
			"borracha":
				_draw_brush(pos, Color(0, 0, 0, 0))
			"picker":
				_pick_color(pos)
			"balde":
				_flood_fill(pos, draw_color)
		tex.update(img)

	elif event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
		if draw_mode in ["pincel", "borracha"]:
			var pos = color_layer.get_local_mouse_position()
			_draw_brush(pos, draw_color if draw_mode == "pincel" else Color(0,0,0,0))
			tex.update(img)


# === Pincel ===
func _draw_brush(pos: Vector2, color: Color):
	for x in range(-brush_size, brush_size):
		for y in range(-brush_size, brush_size):
			var p = Vector2i(pos.x + x, pos.y + y)
			if p.x >= 0 and p.y >= 0 and p.x < img.get_width() and p.y < img.get_height():
				if Vector2(x,y).length() <= brush_size:
					var desen_px = int(float(p.x) / img.get_width() * desenho_img.get_width())
					var desen_py = int(float(p.y) / img.get_height() * desenho_img.get_height())
					var base_color = desenho_img.get_pixel(desen_px, desen_py)
					var brightness = (base_color.r + base_color.g + base_color.b) / 3.0
					if brightness < 0.25:
						continue
					img.set_pixelv(p, color)


# === Comparação de cores ===
func _color_close(a: Color, b: Color, tol: float) -> bool:
	var dr = abs(a.r - b.r)
	var dg = abs(a.g - b.g)
	var db = abs(a.b - b.b)
	var da = abs(a.a - b.a)
	return max(dr, dg, db, da) <= tol


# === Balde ===
func _flood_fill(start: Vector2, new_color: Color):
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


# === Picker ===
func _pick_color(pos: Vector2):
	var c = img.get_pixelv(Vector2i(pos))
	if c.a > 0:
		draw_color = c
	elif picker:
		draw_color = picker.color
	print("Cor escolhida: ", draw_color)


# ==== BOTÕES ====
func _on_pincel_pressed():
	draw_mode = "pincel"

func _on_borracha_pressed():
	draw_mode = "borracha"

func _on_balde_pressed():
	draw_mode = "balde"

func _on_colorpicker_pressed():
	draw_mode = "picker"


# ==== COLOR PICKER ====
func _on_color_picker_color_changed(color: Color):
	draw_color = color
	print("Cor alterada para: ", color)

func _on_texture_button_pressed():
	if not picker:
		push_warning("Picker não definido; verifique Picker Path no Inspector.")
		return
	var popup := picker.get_popup()
	if popup:
		popup.popup_centered()
		popup.grab_focus()
