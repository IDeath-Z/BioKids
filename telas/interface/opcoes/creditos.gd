extends Control

signal botao_voltar_pressed
signal animacao_botao_voltar_finished

func _on_botao_voltar_pressed() -> void:
	botao_voltar_pressed.emit()

func _on_animacao_botao_voltar_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade":
		animacao_botao_voltar_finished.emit()
