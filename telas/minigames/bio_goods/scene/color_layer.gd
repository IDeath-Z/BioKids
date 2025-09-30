extends TextureRect

@export var brush_radius := 16
@export var brush_color := Color(1, 0, 0, 1) # mude a cor aqui depois ligaremos ao ColorPicker

var img: Image
var tex: ImageTexture

func _ready():
	# cria uma tela transparente proporcional ao retângulo
	var w := int(max(1.0, size.x))
	var h := int(max(1.0, size.y))
	img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))  # transparente
	tex = ImageTexture.create_from_image(img)
	texture = tex  # o shader usa TEXTURE

	stretch_mode = TextureRect.STRETCH_SCALE  # preencher o retângulo

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_paint_at(event.position)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_paint_at(event.position)

func _paint_at(local_pos: Vector2) -> void:
	# posição local -> coordenadas da imagem
	var uv := local_pos / size
	if uv.x < 0.0 or uv.x > 1.0 or uv.y < 0.0 or uv.y > 1.0:
		return
	var px := int(uv.x * img.get_width())
	var py := int(uv.y * img.get_height())

	img.lock()
	for y in -brush_radius:brush_radius+1:
		var yy := py + y
		if yy < 0 or yy >= img.get_height(): continue
		var y2 := y * y
		for x in -brush_radius:brush_radius+1:
			if x * x + y2 <= brush_radius * brush_radius:
				var xx := px + x
				if xx < 0 or xx >= img.get_width(): continue
				# mistura alfa simples
				var dst := img.get_pixel(xx, yy)
				var src := brush_color
				var out_a := src.a + dst.a * (1.0 - src.a)
				var out_rgb := (src.rgb * src.a + dst.rgb * dst.a * (1.0 - src.a)) / max(out_a, 0.00001)
				img.set_pixel(xx, yy, Color(out_rgb.x, out_rgb.y, out_rgb.z, out_a))
	img.unlock()
	tex.update(img)
