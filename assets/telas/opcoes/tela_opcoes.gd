extends Control

@onready var animacao_urso = $TexturaUrso/AnimacaoUrso
@onready var textura_urso = $TexturaUrso
var botao_pressionado = ""

func _ready() -> void:
	textura_urso.visible = false
	animacao_urso.play_backwards("sair_tela")

func animacao() -> void:
	animacao_urso.play("sair_tela")
	
func _on_animacao_urso_animation_started(anim_name: StringName) -> void:
	await get_tree().create_timer(0.1).timeout
	textura_urso.visible = true

func _on_animacao_urso_animation_finished(anim_name: StringName) -> void:
	match botao_pressionado:
		"voltar":
			EstadoVariaveisGlobais.urso_saiu_tela_menu = true
			get_tree().change_scene_to_file("res://assets/telas/inicio/tela_inicial.tscn")
				
func _on_botao_voltar_pressed() -> void:
	botao_pressionado = "voltar"
	animacao()
