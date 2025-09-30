extends Control

@onready var fact_label: Label = $FactLabel
@onready var bio_fato = $BioFato

var facts: Array[String] = [
	"Arroz é uma das maiores fontes de energia no mundo.",
	"Feijão é rico em ferro, importante para o sangue.",
	"Batata é cheia de carboidratos, que dão energia rápida.",
	"Brócolis tem mais vitamina C que muitas frutas.",
	"Cenoura tem betacaroteno, que ajuda na visão.",
	"Kiwi tem quase o dobro de vitamina C da laranja.",
	"Laranja fortalece o sistema de defesa do corpo.",
	"Maçã ajuda a limpar os dentes enquanto mastigamos.",
	"Ovo cozido tem proteínas que fortalecem os músculos.",
	"Pimentão é rico em vitamina A e C.",
	"Suco natural tem nutrientes que os artificiais não têm.",
	"Tomate tem licopeno, que protege o coração.",
	"Uva tem antioxidantes que retardam o envelhecimento das células."
]

func _ready() -> void:
	if fact_label == null:
		print("Erro: Nó FactLabel não encontrado dentro de BioFato!")
		return
	var random_index = randi() % facts.size()
	fact_label.text = facts[random_index]
	
	# Configura o autowrap e define o tamanho e posição
	fact_label.autowrap_mode = TextServer.AUTOWRAP_WORD  # Quebra por palavra
	fact_label.size = Vector2(485, 130)  # Define o tamanho exato de 485x130
	fact_label.position = Vector2(115, 525)  # Posição base
	
	# Alinha o texto ao centro horizontal e vertical dinâmico
	fact_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER  # Centraliza horizontalmente
	
	# Estima o número de linhas e centraliza verticalmente
	var font_height = fact_label.get_theme_font("normal_font").get_height(fact_label.get_theme_font_size("normal_font"))
	var estimated_lines = ceil(130 / font_height)  # Estimativa de linhas com base na altura
	var vertical_offset = (130 - (estimated_lines * font_height)) / 2  # Centraliza verticalmente
	fact_label.position.y += vertical_offset  # Ajusta a posição vertical
	
	if not bio_fato.is_connected("botao_continuar_pressed", Callable(self, "_on_botao_continuar_pressed")):
		print("Sinal não conectado automaticamente, conectando agora...")
		var error = bio_fato.botao_continuar_pressed.connect(_on_botao_continuar_pressed)
		if error != OK:
			print("Erro ao conectar o sinal: ", error)
	else:
		print("Sinal botao_continuar_pressed já conectado!")

func _on_botao_continuar_pressed() -> void:
	print("Função _on_botao_continuar_pressed chamada!")
	
	# Para a música do jogo (se existir)
	var background_music = get_parent().get_parent().background_music if get_parent().get_parent().has_node("UILayer/BackgroundMusic") else null
	if background_music:
		background_music.stop()
		print("Música do jogo parada!")
	else:
		print("Erro: BackgroundMusic não encontrado!")
	
	# Restaura o estado original da música da home e reseta flags do minigame
	if EstadoVariaveisGlobais:
		EstadoVariaveisGlobais.musica_ligada = EstadoVariaveisGlobais.minigame_vitaminas_music_on
		EstadoVariaveisGlobais.in_minigame_vitaminas = false
		EstadoVariaveisGlobais.minigame_vitaminas_music_on = false
		print("Música da home restaurada para estado original: ", EstadoVariaveisGlobais.musica_ligada)
	else:
		print("Erro: EstadoVariaveisGlobais não encontrado! Tentando iniciar música diretamente...")
		var music_player = get_node_or_null("/root/MusicPlayer")
		if music_player and get_parent().get_parent().musica_ligada_original:
			music_player.play_music()
			print("Música da home iniciada diretamente via MusicPlayer!")
		else:
			if not music_player:
				print("Erro: MusicPlayer não encontrado!")
			else:
				print("Música da home não iniciada porque musica_ligada_original é false")
	
	# Muda para a cena main
	var scene_path = "res://telas/minigames/missao_vitaminas/Cenas/main.tscn"
	var erro = get_tree().change_scene_to_file(scene_path)
	if erro != OK:
		print("Erro ao carregar cena ", scene_path, ": ", erro)
	else:
		print("Cena ", scene_path, " carregada com sucesso!")
	
	queue_free()
