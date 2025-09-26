extends Node2D

# Garante que a cena principal seja incluída no APK
@onready var cena_main = preload("res://Cenas/main.tscn")

func _ready() -> void:
	var back_button = $BackButton
	if back_button:
		# Desconecta sinal existente para evitar duplicatas
		if back_button.pressed.is_connected(_on_back_button_pressed):
			back_button.pressed.disconnect(_on_back_button_pressed)
		back_button.pressed.connect(_on_back_button_pressed)

		# Configurações pra garantir que funciona no touch
		back_button.focus_mode = Control.FOCUS_ALL
		back_button.mouse_filter = Control.MOUSE_FILTER_STOP
		back_button.disabled = false

		print("BackButton configurado: disabled = ", back_button.disabled, ", mouse_filter = ", back_button.mouse_filter)
	else:
		print("Erro: BackButton não encontrado! Verifique se o nó BackButton existe em info.tscn.")

func _on_back_button_pressed() -> void:
	print("BackButton pressionado! Plataforma: ", OS.get_name())  # Depuração
	var error = get_tree().change_scene_to_packed(cena_main)
	if error != OK:
		print("Erro ao carregar main.tscn: ", error)
	else:
		print("Cena main.tscn carregada com sucesso!")
