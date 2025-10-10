extends Node

@onready var music_player = $AudioStreamPlayer

var musica_volume: float = 1.0

func _ready() -> void:
	if not music_player.playing:
		music_player.play()

func _process(delta: float) -> void:
	if not music_player.playing and EstadoVariaveisGlobais.musica_ligada:
		music_player.play()
	elif music_player.playing and not EstadoVariaveisGlobais.musica_ligada:
		music_player.stop()

func _on_audio_stream_player_finished() -> void:
	music_player.play()

func trocar_musica(music_stream: AudioStream):
	music_player.stream = music_stream
	music_player.play()
	
func set_musica_volume(volume: float) -> void:
	musica_volume = clamp(volume, 0.0, 1.0)
	var volume_db = linear_to_db(musica_volume)
	music_player.volume_db = volume_db
