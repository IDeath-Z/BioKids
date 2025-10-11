extends Node2D

@onready var animacao_urso = $animacao_urso
@onready var animacao_medalha = $medalha
#@onready var music_player = $"../../music_player/AudioStreamPlayer"


func _ready():
	MusicPlayer.parar_para_evento_especial()
	var player_de_audio = MusicPlayer.music_player
	
	player_de_audio.stream = preload("res://telas/minigames/jogo_vacina/sounds/you-win-sequence-2-183949.wav")
	
	player_de_audio.volume_db = -80.0
	player_de_audio.play()

	var tween = create_tween()
	# Sintaxe: tween_property(objeto, "propriedade", valor_final, duração_em_segundos)
	tween.tween_property(player_de_audio, "volume_db", -1, 0.5)
	# O volume irá de -80.0dB para -10dB em 2.0 segundos. Você pode ajustar esse tempo!
	
	await get_tree().create_timer(1.5).timeout
	animacao_urso.play("urso_heroi")
	await get_tree().create_timer(1.5).timeout
	animacao_medalha.play("medalha_conquista")
	await animacao_urso.animation_finished
	player_de_audio.stop()
	get_tree().change_scene_to_file("res://telas/minigames/jogo_vacina/cenas/bio_fato_vacina.tscn")
