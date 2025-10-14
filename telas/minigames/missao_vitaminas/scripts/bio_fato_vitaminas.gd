extends Control

@onready var fact_label: Label = $FactLabel
@onready var bio_fato = $BioFato
@onready var audio_player: AudioStreamPlayer = $AudioPlayer

var facts: Array[String] = [
	"O arroz é uma das maiores fontes de energia no mundo.",
	"O feijão é rico em ferro, importante para o sangue.",
	"A batata é cheia de carboidratos, que dão energia rápida.",
	"O brócolis tem mais vitamina C que muitas frutas.",
	"A cenoura tem betacaroteno, que ajuda na visão.",
	"O kiwi tem quase o dobro de vitamina C da laranja.",
	"A laranja fortalece o sistema de defesa do corpo.",
	"A maçã ajuda a limpar os dentes enquanto mastigamos.",
	"O ovo cozido tem proteínas que fortalecem os músculos.",
	"O pimentão é rico em vitamina A e C.",
	"O suco natural tem nutrientes que os artificiais não têm.",
	"O tomate tem licopeno, que protege o coração.",
	"A uva tem antioxidantes que retardam o envelhecimento das células."
]

var fact_audios: Array[String] = [
	"res://telas/minigames/missao_vitaminas/sounds/BioSom/Arrozz.mp3",
	"res://telas/minigames/missao_vitaminas/sounds/BioSom/Feijaoo.mp3",
	"res://telas/minigames/missao_vitaminas/sounds/BioSom/Batataa.mp3",
	"res://telas/minigames/missao_vitaminas/sounds/BioSom/Brocoliss.mp3",
	"res://telas/minigames/missao_vitaminas/sounds/BioSom/Cenouraa.mp3",
	"res://telas/minigames/missao_vitaminas/sounds/BioSom/Kiwii.mp3",
	"res://telas/minigames/missao_vitaminas/sounds/BioSom/Laranjaa.mp3",
	"res://telas/minigames/missao_vitaminas/sounds/BioSom/Macaa.mp3",
	"res://telas/minigames/missao_vitaminas/sounds/BioSom/Ovoo.mp3",
	"res://telas/minigames/missao_vitaminas/sounds/BioSom/Pimentaoo.mp3",
	"res://telas/minigames/missao_vitaminas/sounds/BioSom/Sucoo.mp3",
	"res://telas/minigames/missao_vitaminas/sounds/BioSom/Tomatee.mp3",
	"res://telas/minigames/missao_vitaminas/sounds/BioSom/Uvaa.mp3"
]

var current_index: int = 0  

func _ready() -> void:
	if fact_label == null:
		print("Erro: Nó FactLabel não encontrado dentro de BioFato!")
		return

	
	current_index = randi() % facts.size()
	fact_label.text = facts[current_index]

	
	fact_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	fact_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var font_height = fact_label.get_theme_font("normal_font").get_height(fact_label.get_theme_font_size("normal_font"))
	var estimated_lines = ceil(130 / font_height)
	var vertical_offset = (130 - (estimated_lines * font_height)) / 2
	fact_label.position.y += vertical_offset

	
	if not bio_fato.is_connected("botao_continuar_pressed", Callable(self, "_on_botao_continuar_pressed")):
		bio_fato.botao_continuar_pressed.connect(_on_botao_continuar_pressed)
	if not bio_fato.is_connected("botao_audio_pressed", Callable(self, "_on_botao_audio_pressed")):
		bio_fato.botao_audio_pressed.connect(_on_botao_audio_pressed)

	print("Fato sorteado:", fact_label.text)

func _on_botao_audio_pressed() -> void:
	print("Botão de áudio pressionado! Índice:", current_index)
	if current_index < fact_audios.size():
		var audio_path = fact_audios[current_index]
		var stream = load(audio_path)
		if stream:
			audio_player.stream = stream
			audio_player.play()
			print("Reproduzindo:", audio_path)
		else:
			print("Erro ao carregar o som:", audio_path)
	else:
		print("Índice de áudio inválido!")

func _on_botao_continuar_pressed() -> void:
	print("Função _on_botao_continuar_pressed chamada!")
	
	var background_music = get_parent().get_parent().background_music if get_parent().get_parent().has_node("UILayer/BackgroundMusic") else null
	if background_music:
		background_music.stop()
	
	if EstadoVariaveisGlobais:
		EstadoVariaveisGlobais.musica_ligada = EstadoVariaveisGlobais.minigame_vitaminas_music_on
		EstadoVariaveisGlobais.in_minigame_vitaminas = false
		EstadoVariaveisGlobais.minigame_vitaminas_music_on = false
	else:
		var music_player = get_node_or_null("/root/MusicPlayer")
		if music_player and get_parent().get_parent().musica_ligada_original:
			music_player.play_music()
	
	var scene_path = "res://telas/minigames/missao_vitaminas/Cenas/main.tscn"
	var erro = get_tree().change_scene_to_file(scene_path)
	if erro != OK:
		print("Erro ao carregar cena ", scene_path, ": ", erro)
	else:
		print("Cena ", scene_path, " carregada com sucesso!")
	
	queue_free()

func _on_bio_fato_botao_audio_pressed() -> void:
	pass # Replace with function body.
