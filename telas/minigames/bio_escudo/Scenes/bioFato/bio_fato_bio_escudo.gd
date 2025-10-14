extends Control

@onready var label = $BioFato/Texto
@onready var audio_player = $BioFato/Biofato_01

# lista de mensagens e sons correspondentes
var mensagens = [
	{
		"text": "Você sabia que os médicos usam jalecos para se proteger e para te proteger de bactérias malvadas e sujeira? Usar jaleco é legal!",
		"audio": "res://telas/minigames/bio_escudo/assets/sounds/biofato_01.wav"
	},
	{
		"text": "Você sabia que as luvas dos médicos funcionam como um escudo invisível contra germes?",
		"audio": "res://telas/minigames/bio_escudo/assets/sounds/biofato_02.wav"
	},
	{
		"text": "O jaleco branco é o símbolo dos médicos! Ele mostra que a pessoa está pronta para cuidar de quem precisa.",
		"audio": "res://telas/minigames/bio_escudo/assets/sounds/biofato_03.wav"
	},
	{
		"text": "Sabia que os médicos sempre lavam as mãos antes e depois de atender um paciente? É um superpoder contra as bactérias!",
		"audio": "res://telas/minigames/bio_escudo/assets/sounds/biofato_04.wav"
	},
	{
		"text": "A máscara do doutor não serve só pra estilo — ela ajuda a proteger o nariz e a boca das sujeirinhas do ar!",
		"audio": "res://telas/minigames/bio_escudo/assets/sounds/biofato_05.wav"
	},
	{
		"text": "Os médicos usam touquinhas pra evitar que cabelos caiam nos instrumentos. Legal, né?",
		"audio": "res://telas/minigames/bio_escudo/assets/sounds/biofato_06.wav"
	}
]

var mensagem_atual = null
	
func _ready():
	if MusicPlayer:
		MusicPlayer.restaurar_gerenciamento_automatico()
		MusicPlayer.mudar_volume(0.2) # diminui o volume enquanto toca
		if not MusicPlayer.music_player.playing:
			MusicPlayer.music_player.play()
	randomize()
	
	mensagem_atual = mensagens[randi() % mensagens.size()]
	label.text = mensagem_atual["text"]

	var stream = load(mensagem_atual["audio"])
	audio_player.stream = stream



func _on_bio_fato_botao_audio_pressed() -> void:
	# Toca apenas o áudio da mensagem atual
	if audio_player.playing:
		audio_player.stop()
	audio_player.play()


func _on_bio_fato_botao_continuar_pressed() -> void:
	if MusicPlayer:
		MusicPlayer.mudar_volume(1.0)
	get_tree().change_scene_to_file("res://telas/minigames/bio_escudo/Scenes/main.tscn")
