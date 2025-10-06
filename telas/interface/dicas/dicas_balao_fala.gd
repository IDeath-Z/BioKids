extends Control

signal botao_audio_pressed

func _on_botao_audio_pressed() -> void:
	botao_audio_pressed.emit()
