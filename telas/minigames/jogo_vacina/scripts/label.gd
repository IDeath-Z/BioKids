extends Label

@export var tempo_pulso: float = 1.2 # velocidade de cada pulso
@export var duracao_total: float = 12.0 # quanto tempo a animação dura no total

func _ready() -> void:
	await _iniciar_pulsacao()

func _iniciar_pulsacao() -> void:
	var pulse_tween = get_tree().create_tween()
	pulse_tween.set_loops()
	
	pulse_tween.tween_property(self, "scale", Vector2(1.1, 1.1), tempo_pulso).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse_tween.tween_property(self, "scale", Vector2(1, 1), tempo_pulso).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Espera o tempo total e para o tween
	await get_tree().create_timer(duracao_total).timeout
	pulse_tween.kill() # encerra o tween
	self.scale = Vector2(1, 1) # volta ao tamanho normal
