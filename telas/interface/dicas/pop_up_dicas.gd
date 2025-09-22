extends Control

signal botao_audio_pressed

@onready var cor_de_fundo = $ColorRect

func _ready() -> void:
	cor_de_fundo.visible = false

func _on_botao_audio_pressed() -> void:
	botao_audio_pressed.emit()
