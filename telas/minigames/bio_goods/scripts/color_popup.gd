extends PopupPanel

signal color_chosen(color: Color)

func _ready():
	# --- BLOQUEIA HERANÇA DO TEMA GLOBAL ---
	theme = Theme.new()  # cria um tema vazio, sem herança

	# --- CONECTA OS BOTÕES DE COR ---
	for button in $VBoxContainer.get_children():
		button.pressed.connect(_on_color_pressed.bind(button))

func _on_color_pressed(button: Button):
	var color = button.get_meta("paint_color")
	emit_signal("color_chosen", color)
	hide()
