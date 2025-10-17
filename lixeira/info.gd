extends Control


@onready var cena_main = preload("res://telas/minigames/missao_vitaminas/Cenas/main.tscn")

func _ready() -> void:
	var back_button = $BackButton
	if back_button:
		
		if back_button.pressed.is_connected(_on_back_button_pressed):
			back_button.pressed.disconnect(_on_back_button_pressed)
		back_button.pressed.connect(_on_back_button_pressed)

		
		back_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		back_button.focus_mode = Control.FOCUS_ALL
		back_button.mouse_filter = Control.MOUSE_FILTER_STOP
		back_button.disabled = false

		print("BackButton configurado: disabled = ", back_button.disabled, ", mouse_filter = ", back_button.mouse_filter)
	else:
		print("Erro: BackButton não encontrado! Verifique se o nó BackButton existe em info.tscn.")

func _on_back_button_pressed() -> void:
	print("BackButton pressionado! Plataforma: ", OS.get_name())  
	var erro = get_tree().change_scene_to_packed(cena_main)
	if erro != OK:
		print("Erro ao carregar main.tscn: ", erro)
	else:
		print("Cena main.tscn carregada com sucesso!")
