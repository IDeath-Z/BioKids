extends Control

signal botao_audio_pressed
signal botao_voltar_pressed

@onready var cor_de_fundo = $ColorRect
@onready var botao_voltar = $AspectRatioContainer2/BotaoVoltar

func _ready() -> void:
	cor_de_fundo.visible = false

func _on_botao_audio_pressed() -> void:
	botao_audio_pressed.emit()

func _on_botao_voltar_pressed() -> void:
	botao_voltar_pressed.emit()
