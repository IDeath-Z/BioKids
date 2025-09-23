extends Area2D

@onready var braco = $braco
@onready var seringa = $imagem_sering
@onready var mao_click = $"../MaoClick"
@onready var timer_mao = $"../TimerMao"
var segurando = false
var toque = Vector2.ZERO
var toque_na_tela = false

func _ready():
	braco.visible = false
	seringa.visible = false
	connect("area_entered", Callable(self, "_on_area_entered"))
	timer_mao.start()
	mao_click.hide()

func _on_touch_screen_pressed() -> void:
	mao_click.hide()
	mao_click.stop()
	toque_na_tela = true
	
func _on_timer_mao_timeout() -> void:
	if !toque_na_tela:
		mao_click.show()
		mao_click.play("click")
	
func _input(event):
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.pressed:
			segurando = true
			toque = global_position - event.position
			braco.visible = true
			seringa.visible = true
			
			mao_click.hide()
			mao_click.stop()
			toque_na_tela = true
			
		else:
			segurando = false
			braco.visible = false
			seringa.visible = false

	elif event is InputEventMouseMotion or event is InputEventScreenDrag:
		if segurando:
			global_position = event.position + toque

func _on_area_entered(area):
	if area.name == "local_vacina":
		get_tree().change_scene_to_file("res://telas/minigames/jogo_vacina/cenas/Conquista_01.tscn")
