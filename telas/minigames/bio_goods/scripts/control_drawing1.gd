extends Control

var draw_mode: String = "pincel"  # modos: pincel, balde, borracha, picker
var draw_color: Color = Color(1, 0, 0) # vermelho padrão
var brush_size: int = 8

@onready var color_layer: TextureRect = $GridImage/ColorLayer
var img: Image
var tex: ImageTexture


func _ready():
	# pega o tamanho do Desenho (imagem de fundo)
	var desenho_node = $GridImage/Desenho
	color_layer.size = desenho_node.size

	var w = max(1, int(color_layer.size.x))
	var h = max(1, int(color_layer.size.y))

	img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0)) # transparente

	tex = ImageTexture.create_from_image(img)
	color_layer.texture = tex



func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var pos = event.position - color_layer.global_position
		match draw_mode:
			"pincel":
				_draw_brush(pos, draw_color)
			"borracha":
				_draw_brush(pos, Color(0, 0, 0, 0)) # apaga
			"picker":
				var c = img.get_pixelv(pos)
				if c.a > 0:
					draw_color = c
			"balde":
				_flood_fill(pos, draw_color)

		tex.update(img)

	elif event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		if draw_mode in ["pincel", "borracha"]:
			var pos = color_layer.get_local_mouse_position()
			_draw_brush(pos, draw_color if draw_mode == "pincel" else Color(0,0,0,0))
			tex.update(img)


func _draw_brush(pos: Vector2, color: Color):
	for x in range(-brush_size, brush_size):
		for y in range(-brush_size, brush_size):
			var p = Vector2i(pos.x + x, pos.y + y)
			if p.x >= 0 and p.y >= 0 and p.x < img.get_width() and p.y < img.get_height():
				if Vector2(x,y).length() <= brush_size:
					img.set_pixelv(p, color)


func _flood_fill(start: Vector2, new_color: Color):
	# Implementação simples de flood fill
	var target = img.get_pixelv(start)
	if target == new_color:
		return
	var stack = [Vector2i(start)]
	while stack.size() > 0:
		var p = stack.pop_back()
		if p.x < 0 or p.y < 0 or p.x >= img.get_width() or p.y >= img.get_height():
			continue
		if img.get_pixelv(p) != target:
			continue
		img.set_pixelv(p, new_color)
		stack.append(Vector2i(p.x+1, p.y))
		stack.append(Vector2i(p.x-1, p.y))
		stack.append(Vector2i(p.x, p.y+1))
		stack.append(Vector2i(p.x, p.y-1))


# ==== BOTÕES ====
func _on_pincel_pressed():
	draw_mode = "pincel"
	print("Modo alterado para: pincel")

func _on_borracha_pressed():
	draw_mode = "borracha"
	print("Modo alterado para: borracha")

func _on_balde_pressed():
	draw_mode = "balde"
	print("Modo alterado para: balde")

func _on_colorpicker_pressed():
	draw_mode = "picker"
	print("Modo alterado para: picker")

func _on_color_picker_color_changed(color: Color):
	draw_color = color
	print("Cor alterada para: ", color)
