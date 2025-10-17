extends Control

@onready var botao_voltar = $AspectRatioContainer2/BotaoVoltar

signal botao_voltar_pressed

func _on_botao_voltar_pressed() -> void:
	botao_voltar_pressed.emit()
