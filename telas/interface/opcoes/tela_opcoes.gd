extends Control

enum Estado {
	INICIAL, # 0
	CREDITOS # 1
}

@onready var botao_musica = $MarginContainer/GridBotoes/BotaoMusica
@onready var animacao_opcoes = $TexturaOpcoes/AnimacaoOpcoes
@onready var animacao_urso = $TexturaUrso/AnimacaoUrso
@onready var textura_opcoes = $TexturaOpcoes
@onready var textura_urso = $TexturaUrso
@onready var animacao_creditos = $Creditos/AnimacaoCreditos
@onready var animacao_creditos_botao_voltar = $Creditos/BotaoVoltar/AnimacaoBotaoVoltar

var botao_pressionado = ""
var estado_atual = Estado.INICIAL

func _ready() -> void:
	textura_opcoes.visible = false
	textura_urso.visible = false
	animacao_opcoes.play("fade_out")
	animacao_urso.play_backwards("sair_tela")

func _on_botao_musica_pressed() -> void:
	if EstadoVariaveisGlobais.musica_ligada == true:
		EstadoVariaveisGlobais.musica_ligada = false
		botao_musica.text = "Musica : Desligada"
	elif EstadoVariaveisGlobais.musica_ligada == false:
		EstadoVariaveisGlobais.musica_ligada = true
		botao_musica.text = "Musica : Ligada"

func _on_botao_creditos_pressed() -> void:
	estado_atual = Estado.CREDITOS
	animacao_urso.play("sair_tela")
	animacao_creditos.play("entrar_tela")
				
func _on_botao_voltar_pressed() -> void:
	botao_pressionado = "voltar"
	animacao()
	
func _on_creditos_botao_voltar_pressed() -> void:
	estado_atual = Estado.INICIAL
	animacao_creditos_botao_voltar.play_backwards("fade")

func animacao() -> void:
	animacao_opcoes.play_backwards("fade_out")
	animacao_urso.play("sair_tela")
	
func _on_animacao_urso_animation_started(anim_name: StringName) -> void:
	await get_tree().create_timer(0.1).timeout
	textura_opcoes.visible = true
	textura_urso.visible = true

func _on_animacao_urso_animation_finished(anim_name: StringName) -> void:
	match botao_pressionado:
		"voltar":
			EstadoVariaveisGlobais.urso_saiu_tela_menu = true
			get_tree().change_scene_to_file("res://telas/interface/inicio/tela_inicial.tscn")

func _on_animacao_creditos_animation_finished(anim_name: StringName) -> void:
	if anim_name == "entrar_tela":
		if estado_atual == Estado.CREDITOS:
			animacao_creditos_botao_voltar.play("fade")
		else:
			animacao_urso.play_backwards("sair_tela")

func _on_creditos_animacao_botao_voltar_finished() -> void:
	if estado_atual == Estado.INICIAL:
		animacao_creditos.play_backwards("entrar_tela")
