extends Control

signal botao_audio_pressed
signal botao_continuar_pressed

@onready var botao_continuar = $BotaoContinuar

func _on_botao_continuar_pressed() -> void:
	botao_continuar_pressed.emit()


func _on_botao_audio_pressed() -> void:
	botao_audio_pressed.emit()
