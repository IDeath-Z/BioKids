extends Control

signal continue_pressed

@onready var continue_button = $PanelContainer/VBoxContainer/ContinueButton
@onready var exit_button = $PanelContainer/VBoxContainer/ExitButton

func _ready():
	visible = false
	
	if continue_button == null:
		push_error("ERRO CRÍTICO: ContinueButton não encontrado! Verifique o caminho $PanelContainer/VBoxContainer/ContinueButton na cena PauseMenu.tscn")
		print("Estrutura da cena: PanelContainer = ", $PanelContainer, ", VBoxContainer = ", $PanelContainer/VBoxContainer if $PanelContainer else null)
	else:
		continue_button.pressed.connect(_on_continue_button_pressed)
		continue_button.focus_mode = Control.FOCUS_ALL
		continue_button.mouse_filter = Control.MOUSE_FILTER_STOP
		continue_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		continue_button.disabled = false
		continue_button.visible = true
		continue_button.mouse_entered.connect(_on_continue_button_mouse_entered)
		continue_button.mouse_exited.connect(_on_continue_button_mouse_exited)
		continue_button.button_down.connect(_on_continue_button_down)
		continue_button.button_up.connect(_on_continue_button_up)
		print("ContinueButton inicializado e conectado: visible = ", continue_button.visible, ", disabled = ", continue_button.disabled, ", global_rect = ", continue_button.get_global_rect())
	
	if exit_button == null:
		push_error("ERRO CRÍTICO: ExitButton não encontrado! Verifique o caminho $PanelContainer/VBoxContainer/ExitButton na cena PauseMenu.tscn")
		print("Estrutura da cena: PanelContainer = ", $PanelContainer, ", VBoxContainer = ", $PanelContainer/VBoxContainer if $PanelContainer else null)
	else:
		exit_button.pressed.connect(_on_exit_button_pressed)
		exit_button.focus_mode = Control.FOCUS_ALL
		exit_button.mouse_filter = Control.MOUSE_FILTER_STOP
		exit_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		exit_button.disabled = false
		exit_button.visible = true
		exit_button.mouse_entered.connect(_on_exit_button_mouse_entered)
		exit_button.mouse_exited.connect(_on_exit_button_mouse_exited)
		exit_button.button_down.connect(_on_exit_button_down)
		exit_button.button_up.connect(_on_exit_button_up)
		print("ExitButton inicializado e conectado: visible = ", exit_button.visible, ", disabled = ", exit_button.disabled, ", global_rect = ", exit_button.get_global_rect())
	
	print("PauseMenu _ready() concluído: ContinueButton = ", continue_button, ", ExitButton = ", exit_button)

func show_menu():
	print("Executando show_menu() no PauseMenu: visibilidade atual = ", visible, ", modulate.a = ", modulate.a)
	visible = true
	modulate.a = 1.0  # Garante que a opacidade seja 100%
	if continue_button:
		continue_button.grab_focus()
		print("Foco dado ao ContinueButton, visibilidade = ", continue_button.visible, ", modulate.a = ", continue_button.modulate.a)
	else:
		print("ERRO: ContinueButton não encontrado ao mostrar menu!")
	if exit_button:
		print("ExitButton visível = ", exit_button.visible, ", modulate.a = ", exit_button.modulate.a)
	else:
		print("ERRO: ExitButton não encontrado ao mostrar menu!")
	print("Menu de pausa exibido: foco no ContinueButton, visible = ", visible, ", modulate.a = ", modulate.a)

func hide_menu():
	visible = false
	print("Menu de pausa escondido: visible = ", visible)

func _on_continue_button_pressed():
	print("ContinueButton pressionado no PauseMenu! Emitindo sinal continue_pressed...")
	emit_signal("continue_pressed")

func _on_exit_button_pressed():
	print("ExitButton pressionado no PauseMenu! Reiniciando jogo e voltando à tela inicial...")
	get_tree().paused = false
	var main_node = get_node("../..")
	if main_node and main_node.has_method("reset_game_state"):
		print("Chamando reset_game_state em: ", main_node.name)
		main_node.reset_game_state()
	hide_menu()
	# Recarrega a cena main.tscn como se fosse um novo início
	var erro = get_tree().reload_current_scene()
	if erro != OK:
		print("Erro ao recarregar cena atual: ", erro)
		# Caso o reload falhe, tenta mudar para main.tscn manualmente
		var scene_path = "res://main.tscn"
		var change_error = get_tree().change_scene_to_file(scene_path)
		if change_error != OK:
			print("Erro ao carregar cena ", scene_path, ": ", change_error)
		else:
			print("Cena ", scene_path, " carregada com sucesso!")
	else:
		print("Cena recarregada com sucesso!")

func _on_continue_button_mouse_entered():
	if continue_button and continue_button.visible and not continue_button.disabled:
		var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(continue_button, "modulate", Color(1.5, 1.5, 1.5), 0.2)
		print("Mouse entrou no ContinueButton")

func _on_continue_button_mouse_exited():
	if continue_button and continue_button.visible and not continue_button.disabled:
		var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(continue_button, "modulate", Color(1.0, 1.0, 1.0), 0.2)
		print("Mouse saiu do ContinueButton")

func _on_continue_button_down():
	if continue_button and continue_button.visible and not continue_button.disabled:
		var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(continue_button, "modulate", Color(1.5, 1.5, 1.5), 0.2)
		print("ContinueButton pressionado (down)")

func _on_continue_button_up():
	if continue_button and continue_button.visible and not continue_button.disabled:
		var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(continue_button, "modulate", Color(1.0, 1.0, 1.0), 0.2)
		print("ContinueButton solto (up)")

func _on_exit_button_mouse_entered():
	if exit_button and exit_button.visible and not exit_button.disabled:
		var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(exit_button, "modulate", Color(1.5, 1.5, 1.5), 0.2)
		print("Mouse entrou no ExitButton")

func _on_exit_button_mouse_exited():
	if exit_button and exit_button.visible and not exit_button.disabled:
		var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(exit_button, "modulate", Color(1.0, 1.0, 1.0), 0.2)
		print("Mouse saiu do ExitButton")

func _on_exit_button_down():
	if exit_button and exit_button.visible and not exit_button.disabled:
		var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(exit_button, "modulate", Color(1.5, 1.5, 1.5), 0.2)
		print("ExitButton pressionado (down)")

func _on_exit_button_up():
	if exit_button and exit_button.visible and not exit_button.disabled:
		var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(exit_button, "modulate", Color(1.0, 1.0, 1.0), 0.2)
		print("ExitButton solto (up)")
