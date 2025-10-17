extends Control

@onready var panel = $BubbleSprite
@onready var text_label = $BubbleSprite/Label
@onready var bg = $ColorRect
@onready var bubble_sprite = $BubbleSprite  # 👈 referência ao AnimatedSprite2D
@onready var camera = get_viewport().get_camera_2d()
@onready var voice_player = $VoicePlayer

func shake_camera(duration := 0.4, intensity := 5.0):
	if camera == null:
		return
	var timer := 0.0
	var original_offset = camera.offset
	while timer < duration:
		timer += get_process_delta_time()
		camera.offset = original_offset + Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		await get_tree().process_frame
	camera.offset = original_offset
# Função para trocar a animação do balão
func set_bubble(type: String):
	match type:
		"error":
			bubble_sprite.play("error")
		"success":
			bubble_sprite.play("success")
		_:
			bubble_sprite.play("default")

# Mensagens principais
var messages = [
	"Oi, amiguinho! Que bom te ver!\nVamos vestir o jaleco de doutor no Ursinho Amigo?",
	"Vamos aprender a usar os EPIs corretamente!",
	"Perfeito! Agora coloque o jaleco.",
	]

# Mensagens de erro variadas
var error_messages = {
	"camisa": [
		"Essa não!! Precisamos vestir o jaleco no ursinho!",
		"Tente de novo! O jaleco é o de médico!",
		"Ops, esse não parece o jaleco certo!"
	],
	"pants": [
		"Ops! Essa não é a calça certa, tente novamente!",
		"A calça está errada, tente outra!",
		"Essa calça não combina com o jaleco!"
	],
	"epi": [
		"Faltou algum EPI! Tente de novo!",
		"Lembre-se de colocar todos os EPIs!",
		"Você esqueceu um EPI importante!"
	]
}

func on_player_error(type: String):
	if error_messages.has(type):
		var list = error_messages[type]
		var msg = list[randi() % list.size()]  # aleatória
		set_bubble("error")
		shake_camera()
		show_message(msg)

var current_index = 0
var phase = "intro"  # intro → jaleco → pants → epis → end

func _ready():
	show_message(messages[current_index])
	panel.visible = true
	bg.modulate = Color(0, 0, 0, 0.5)
	set_bubble("default")

func show_message(msg: String):
	text_label.text = msg
	visible = true
	panel.visible = true
	
	# toca voz correspondente
	play_voice_for_message(msg)

func play_voice_for_message(msg: String):
	if voice_player.playing:
		voice_player.stop()

	var stream: AudioStream = null
	
	if msg.begins_with("Oi, amiguinho"):
		stream = load("res://telas/minigames/bio_escudo/assets/sounds/intro01.wav")
	elif msg.begins_with("Vamos aprender"):
		stream = load("res://telas/minigames/bio_escudo/assets/sounds/intro02.wav")
	elif msg.begins_with("Perfeito"):
		stream = load("res://telas/minigames/bio_escudo/assets/sounds/intro03.wav")
	elif msg.begins_with("Essa não"):
		stream = load("res://telas/minigames/bio_escudo/assets/sounds/error_msg01.wav")
	elif msg.begins_with("Tente de novo"):
		stream = load("res://telas/minigames/bio_escudo/assets/sounds/error_msg02.wav")
	elif msg.begins_with("Ops, esse não parece"):
		stream = load("res://telas/minigames/bio_escudo/assets/sounds/error_msg03.wav")
	elif msg.begins_with("Ops") or msg.begins_with("Essa não"):
		stream = load("res://telas/minigames/bio_escudo/assets/sounds/error_msg_pants01.wav")
	elif msg.begins_with("A calça está errada"):
		stream = load("res://telas/minigames/bio_escudo/assets/sounds/error_msg_pants02.wav")
	elif msg.begins_with("Essa calça"):
		stream = load("res://telas/minigames/bio_escudo/assets/sounds/error_msg_pants03.wav")
	elif msg.begins_with("Faltou algum EPI"):
		stream = load("res://telas/minigames/bio_escudo/assets/sounds/error_msg_EPI01.wav")	
	elif msg.begins_with("Lembre-se"):
		stream = load("res://telas/minigames/bio_escudo/assets/sounds/error_msg_EPI02.wav")	
	elif msg.begins_with("Você esqueceu"):
		stream = load("res://telas/minigames/bio_escudo/assets/sounds/error_msg_EPI03.wav")	
	elif msg.begins_with("Excelente"):
		stream = load("res://telas/minigames/bio_escudo/assets/sounds/Succes_msg.wav")	
		
		
	if stream:
		voice_player.stream = stream
		voice_player.play()
func next_message():
	current_index += 1
	if current_index < messages.size():
		show_message(messages[current_index])
	else:
		hide()

func fade_out_bg():
	var tween = create_tween()
	tween.tween_property(bg, "modulate:a", 0.0, 1.5)
	await tween.finished
	bg.visible = false

func on_jaleco_correct():
	if phase == "jaleco":
		set_bubble("success")
		next_message()
		phase = "pants"

func on_pants_correct():
	if phase == "pants":
		set_bubble("success")
		next_message()
		phase = "epis"

func on_epis_correct():
	if phase == "epis":
		set_bubble("success")
		next_message()
		phase = "end"
func show_success_and_continue():
	set_bubble("success")
	show_message("Excelente! Agora você tá pronto pra cuidar de todo mundo com segurança!")
	
	$CheerSound.play()  # toca imediatamente
	
	await get_tree().create_timer(7).timeout  # espera o som tocar um pouco
	
	get_tree().change_scene_to_file("res://telas/minigames/bio_escudo/Scenes/bioFato/bio_fato_bio_escudo.tscn")

	
func _on_texture_button_pressed() -> void:
	if phase == "intro":
		next_message()
		if current_index == 1:
			await fade_out_bg()
			phase = "jaleco"
	else:
		hide()


func _on_botao_audio_pressed() -> void:
	# Reproduz novamente o áudio da mensagem atualmente exibida
	if text_label.text != "":
		play_voice_for_message(text_label.text)
