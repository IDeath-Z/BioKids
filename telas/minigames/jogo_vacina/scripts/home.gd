extends Control

#@onready var menu_botes_tela_principal = $MarginContainerPrincipal
@onready var botao_audio = $TexturaUrso/TexturaBalao/AspectRatioContainer/BotaoAudio
@onready var botao_iniciar = $MarginContainerPrincipal2/GridBotoes/BotaoIniciar
@onready var botao_pular = $BotaoPular
@onready var botao_voltar = $MarginContainerPrincipal2/GridBotoes/BotaoVoltar
@onready var tela_01 = $Tela_01
@onready var box_botoes = $MarginContainerPrincipal2
@onready var textura_balao = $TexturaUrso/TexturaBalao
@onready var animacao_balao = $TexturaUrso/TexturaBalao/AnimacaoBalao
@onready var textura_urso = $TexturaUrso
@onready var animacao_urso = $TexturaUrso/AnimacaoUrso
@onready var logo = $Logo_jogo_vacina
@onready var animacao_botao = $MarginContainerPrincipal2/GridBotoes/AnimacaoBotao
@onready var fala_urso = $TexturaUrso/TexturaBalao/AspectRatioContainer/AudioStreamPlayer

var animacao_reversa: bool

func _ready() -> void:
	textura_balao.visible = false
	textura_urso.visible = false
	botao_pular.visible = false
	botao_pular.z_index = 10
	
	fala_urso.stream = preload("res://telas/minigames/jogo_vacina/sounds/como_jogar_vacina.mp3")
	fala_urso.connect("finished", Callable(self, "_on_fala_urso_audio_finished"))
	
func _on_botao_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/interface/selecaoMiniGame/tela_selecao_mini_game.tscn")
	

func _on_botao_iniciar_pressed() -> void:
	animacao_botao.play("fade")
	textura_balao.visible = true
	textura_urso.visible = true
	animacao_urso.play("entrar_tela")
	animacao_balao.play("fade")
	await animacao_botao.animation_finished
	
	botao_pular.visible = true

func _on_botao_pular_pressed():
	get_tree().change_scene_to_file("res://telas/minigames/jogo_vacina/cenas/main.tscn")
	
func _on_botao_audio_pressed() -> void:
	MusicPlayer.parar_para_evento_especial()
	fala_urso.play()
	
func _on_fala_urso_audio_finished() -> void:
	MusicPlayer.restaurar_gerenciamento_automatico()
