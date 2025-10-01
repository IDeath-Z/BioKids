extends Control

#@onready var menu_botes_tela_principal = $MarginContainerPrincipal
@onready var botao_iniciar = $MarginContainerPrincipal2/GridBotoes/BotaoIniciar
@onready var botao_como_jogar = $MarginContainerPrincipal2/GridBotoes/BotaoComoJogar
@onready var botao_voltar = $MarginContainerPrincipal2/GridBotoes/BotaoVoltar
@onready var tela_02 = $Tela_02
@onready var balao = $Tela_02/TexturaBalao
@onready var texto_balao = $Tela_02/TextoBalao
@onready var urso = $Tela_02/Sprite2D
@onready var tela_01 = $Tela_01
@onready var box_botoes = $MarginContainerPrincipal2
@onready var botao_iniciar2 = $Tela_02/BotaoIniciar2

func _on_botao_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/interface/selecaoMiniGame/tela_selecao_mini_game.tscn")
	
func _on_botao_como_jogar_pressed() -> void:
	chamar_home()

func _on_botao_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/jogo_vacina/cenas/main.tscn")

func chamar_home():
	var largura_tela := 720  # largura da sua tela

	# Inicializar posições
	tela_02.position = Vector2(-largura_tela, 0)  # fora da tela à esquerda
	tela_01.position = Vector2(0, 0)             # tela 01 visível
	tela_02.visible = true
	tela_02.z_index = tela_01.z_index + 1        # garante que tela_02 fique acima de tela_01
	box_botoes.visible = false

	# Inicializar posições dos elementos internos da tela_02
	balao.position = Vector2(11, 369)
	texto_balao.position = Vector2(226, 417)
	urso.position = Vector2(156, 914)

	# Criar um único tween
	var tween = get_tree().create_tween()

	# Tela 2 entra primeiro (começa imediatamente)
	tween.tween_property(tela_02, "position", Vector2(0,0), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Tela 1 sai para a direita, mas com delay de 0.3s
	tween.tween_property(tela_01, "position", Vector2(largura_tela, 0), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_delay(0.3)

	# Callback para esconder tela_01 no final
	tween.finished.connect(Callable(self, "_on_tela01_anim_finished"))

func _on_tela01_anim_finished():
	tela_01.visible = false

func _on_botao_iniciar2_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/jogo_vacina/cenas/main.tscn")
