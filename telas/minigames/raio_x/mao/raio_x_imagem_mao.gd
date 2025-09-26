extends Control

enum Estado {
	INICIAL, # 0
	LADO_ESQUERDO, # 1
	LADO_DIREITO # 2
}

@onready var area_mao = $AreaMao
@onready var animacao_mao = $AreaMao/AnimacaoMao
@onready var texto = $AspectRatioContainerDicas/PopUpDicas/Label
@onready var info_lado_esquerdo = $InfoMaoLadoEsquerdo
@onready var animacao_info_lado_esquerdo = $InfoMaoLadoEsquerdo/AnimacaoLadoEsquerdo
@onready var info_lado_direito = $InfoMaoLadoDireito
@onready var animacao_info_lado_direito = $InfoMaoLadoDireito/AnimacaoLadoDireito
@onready var animacao_texto = $AspectRatioContainerDicas/PopUpDicas/Label/AnimacaoTexto
@onready var botoes_s_n = $HBoxContainer
@onready var botao_sim = $HBoxContainer/BotaoSim
@onready var botao_nao = $HBoxContainer/BotaoNao
@onready var animacao_botoes = $HBoxContainer/AnimacaoBotoes
@onready var botoes_ant_prox = $HBoxContainer2

var estado_atual = Estado.INICIAL

func _ready() -> void:
	area_mao.visible = false
	texto.visible = false
	botoes_s_n.visible = false
	info_lado_esquerdo.visible = false
	info_lado_direito.visible = false
	botoes_ant_prox.visible = false
	animacao_mao.play("fade")
	animacao_texto.play("fade")
	animacao_botoes.play("fade")

func _on_botao_sim_pressed() -> void:
	if estado_atual == Estado.INICIAL:
		estado_atual = Estado.LADO_ESQUERDO
		texto.text = "Estes são os ossos que formam a sua mão! Com eles, você consegue segurar um lápis, montar brinquedos e dar um 'tchauzinho'!"
		animacao_mao.play("lado_esquerdo") # Cai na linha 73
	elif estado_atual == Estado.LADO_DIREITO:
		# Vira o botão "Anterior" pra reaproveitar
		estado_atual = Estado.LADO_ESQUERDO
		botoes_s_n.visible = false
		botoes_ant_prox.visible = true
		animacao_info_lado_direito.play_backwards("fade") # Cai na linha 99
	
func _on_botao_nao_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/raio_x/bio_fato/bio_fato_raio_x.tscn")
	
func _on_botao_anterior_pressed() -> void:
	estado_atual = Estado.INICIAL
	botoes_s_n.visible = true
	botoes_ant_prox.visible = false
	texto.text = "Uau, sua mão em raio-x ficou demais! \n \nQuer conhecer um pouco mais sobre ela?"
	animacao_info_lado_esquerdo.play_backwards("fade") # Cai na 92
		
func _on_botao_proximo_pressed() -> void:
	estado_atual = Estado.LADO_DIREITO
	info_lado_esquerdo.visible = false
	animacao_mao.play("lado_direito") # Cai na linha 83
	
func _on_pop_up_dicas_botao_audio_pressed() -> void:
	# Colocar o audio aqui quando tiver
	pass

func _on_animacao_mao_animation_started(anim_name: StringName) -> void:
	if anim_name == "fade":
		await get_tree().create_timer(0.1).timeout
		area_mao.visible = true
		texto.visible = true
		botoes_s_n.visible = true
		
func _on_animacao_mao_animation_finished(anim_name: StringName) -> void:
	if anim_name == "lado_esquerdo":
		if estado_atual == Estado.LADO_ESQUERDO:
			info_lado_esquerdo.visible = true
			animacao_info_lado_esquerdo.play("fade") # Para aqui
			botoes_s_n.visible = false
			botoes_ant_prox.visible = true
	if anim_name == "lado_direito":
		if estado_atual == Estado.LADO_ESQUERDO:
			info_lado_esquerdo.visible = true
			animacao_info_lado_esquerdo.play("fade") # Para aqui
		if estado_atual == Estado.LADO_DIREITO:
			info_lado_direito.visible = true
			animacao_info_lado_direito.play("fade") # Para aqui
			botoes_s_n.visible = true
			botao_sim.text = "Anterior"
			botao_nao.text = "Sair"
			botoes_ant_prox.visible = false

func _on_animacao_lado_esquerdo_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade":
		if estado_atual == Estado.INICIAL:
			animacao_mao.play_backwards("lado_esquerdo")
			botao_sim.text = "Sim"
			botao_nao.text = "Não"

func _on_animacao_lado_direito_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade":
		if estado_atual == Estado.LADO_ESQUERDO:
			animacao_mao.play_backwards("lado_direito") # Cai na linha 80
