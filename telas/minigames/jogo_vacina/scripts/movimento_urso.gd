#extends AnimatedSprite2D
#
#func _ready() -> void:
	#position = Vector2(380,1300.0)
#
	#var tween = get_tree().create_tween()
	#tween.tween_property(self, "position", Vector2(380.0,1100), 1.1)

extends AnimatedSprite2D

func _ready() -> void:

	var screen_size = get_viewport_rect().size

	# --- Posições Dinâmicas ---
	# Posição X: Centralizado na tela
	var pos_x = screen_size.x / 2 
	
	# Posição Y Inicial: Logo abaixo da parte visível da tela
	var start_pos_y = screen_size.y + 100 # Adicionamos 100 para garantir que ele comece fora
	
	# Posição Y Final: 80% para baixo na tela (ajuste o valor 0.8 como preferir)
	var end_pos_y = screen_size.y * 0.8 

	# Define a posição inicial do urso
	position = Vector2(pos_x, start_pos_y)

	# Cria o tween com as posições calculadas
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(pos_x, end_pos_y), 1.1)
