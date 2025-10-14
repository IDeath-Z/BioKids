extends Control

@onready var player_de_audio = $AudioStreamPlayer

func _ready() -> void:
	# Verificar se o AudioStreamPlayer foi encontrado
	if not player_de_audio:
		push_error("AudioStreamPlayer não encontrado na cena!")
		return
	
	# Carregar o arquivo de áudio do texto
	var audio_path = "res://telas/minigames/bio_goods/scene/selecionar_quadro_audio.mp3"
	if ResourceLoader.exists(audio_path):
		player_de_audio.stream = load(audio_path)
		print("Áudio carregado com sucesso: ", audio_path)
	else:
		push_error("Arquivo de áudio não encontrado: ", audio_path)
	
	# Conectar o sinal finished (opcional, para restaurar a música depois)
	if player_de_audio.stream:
		player_de_audio.finished.connect(_on_audio_finished)
		print("Sinal finished conectado")
	
	# Iniciar com a música de fundo, se disponível
	if MusicPlayer and MusicPlayer.has_method("restaurar_gerenciamento_automatico"):
		MusicPlayer.restaurar_gerenciamento_automatico()
		print("Música de fundo restaurada ao entrar na cena")

func _on_botao_audio_pressed() -> void:
	print("Botão de áudio pressionado!")
	
	if not player_de_audio:
		push_error("player_de_audio é null!")
		return
	
	if not player_de_audio.stream:
		push_error("Nenhum stream de áudio carregado!")
		return
	
	print("Iniciando reprodução do áudio do texto...")
	
	# Pausar a música de fundo antes de tocar o áudio do texto
	if MusicPlayer and MusicPlayer.has_method("parar_para_evento_especial"):
		MusicPlayer.parar_para_evento_especial()
		print("Música de fundo pausada para reproduzir áudio do texto")
	
	player_de_audio.play()
	print("Comando play executado")

func _on_audio_finished() -> void:
	print("Áudio do texto terminado")
	
	# Restaurar a música de fundo após o áudio terminar
	if MusicPlayer and MusicPlayer.has_method("restaurar_gerenciamento_automatico"):
		MusicPlayer.restaurar_gerenciamento_automatico()
		print("Música de fundo restaurada após áudio terminar")

func _on_desenho_1_consultorio_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/bio_goods/scene/desenho1.tscn")

func _on_desenho_2__pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/bio_goods/scene/desenho2.tscn")

func _on_touch_screen_button_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/bio_goods/scene/desenho3.tscn")

func _on_botao_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/bio_goods/scene/home.tscn")
