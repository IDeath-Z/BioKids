extends Label

@export var texto_final: String = "Parabéns!" 
@export var tempo_por_letra: float = 0.1          
@export var duracao_movimento: float = 1.2         
@export var cor_brilho: Color = Color(1, 1, 0.7)  

var tween: Tween

func _ready() -> void:
	text = "" 
	await _mostrar_texto_animado()
	_iniciar_balanço_texto()

func _mostrar_texto_animado() -> void:
	for letra in texto_final:
		text += letra
		modulate = cor_brilho
		await get_tree().create_timer(tempo_por_letra).timeout
		modulate = Color.WHITE

func _iniciar_balanço_texto() -> void:
	if !is_inside_tree():
		return
	
	tween = get_tree().create_tween()
	tween.set_loops()

	tween.tween_property(self, "scale", Vector2(1.1, 1.1), duracao_movimento / 2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), duracao_movimento / 2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(self, "rotation_degrees", 3, duracao_movimento / 2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation_degrees", -3, duracao_movimento)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation_degrees", 0, duracao_movimento / 2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _exit_tree() -> void:
	if tween and tween.is_valid():
		tween.kill()
