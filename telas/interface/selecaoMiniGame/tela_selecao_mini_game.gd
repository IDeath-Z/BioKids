extends Control

@onready var animacao_tela = $AnimacaoTela
@onready var animacao_jogos = $TexturaJogos/AnimacaoJogos
@onready var textura_jogos = $TexturaJogos
var musica_menu: AudioStream = preload("res://telas/interface/assets/sons/musicas/WAV_The_Art_of_Courtship_Requires_Many_Save_Slots.wav")
var saindo_tela = false
var botao_pressionado = ""

func _ready() -> void:
	if EstadoVariaveisGlobais.in_menu_music:
		EstadoVariaveisGlobais.in_menu_music = false
	else:
		print("Entrou aqui")
		MusicPlayer.trocar_musica(musica_menu)
	textura_jogos.visible = false
	animacao_jogos.play("fade_out")

func _on_bio_x_pressed() -> void:
	animacao_jogos.play_backwards("fade_out")
	animacao_tela.play("mover_cenario")
	botao_pressionado = "raioX"

func _on_bio_vacina_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/jogo_vacina/cenas/home.tscn")
	
func _on_caca_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/caca_bacterias/scenes/main_menu.tscn")
	
func _on_missao_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/missao_vitaminas/Cenas/main.tscn")
	
func _on_bio_escudo_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/bio_escudo/Scenes/main.tscn")
	
func _on_bio_goods_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/bio_goods/scene/home.tscn")
	
func _on_botao_voltar_pressed() -> void:
	EstadoVariaveisGlobais.urso_saiu_tela_menu = true
	saindo_tela = true
	animacao_jogos.play_backwards("fade_out")

func _on_animacao_jogos_animation_started(anim_name: StringName) -> void:
	await get_tree().create_timer(0.1).timeout
	textura_jogos.visible = true
	
func _on_animacao_jogos_animation_finished(anim_name: StringName) -> void:
	if saindo_tela == true:
		get_tree().change_scene_to_file("res://telas/interface/inicio/tela_inicial.tscn")

func _on_animacao_tela_animation_finished(anim_name: StringName) -> void:
	if anim_name == "mover_cenario":
		match botao_pressionado:
			"raioX":
				get_tree().change_scene_to_file("res://telas/minigames/raio_x/raio_x_menu.tscn")
