extends Control

@onready var player_de_audio = $AudioStreamPlayer

func _ready() -> void:
	if not player_de_audio:
		push_error("AudioStreamPlayer não encontrado na cena!")
		return

	var audio_path = "res://telas/minigames/bio_goods/scene/bio_fato_audio.mp3"
	if ResourceLoader.exists(audio_path):
		player_de_audio.stream = load(audio_path)
		print("Áudio carregado com sucesso: ", audio_path)
	else:
		push_error("Arquivo de áudio não encontrado: ", audio_path)

	if player_de_audio.stream:
		player_de_audio.finished.connect(_on_bio_fato_audio_finished)
		print("Sinal finished conectado")

	# Desativar música de fundo completamente nesta cena
	if MusicPlayer and MusicPlayer.has_method("parar_para_evento_especial"):
		MusicPlayer.parar_para_evento_especial()
		print("Música de fundo desativada nesta cena")

func _on_botao_audio_pressed() -> void:
	print("Botão de áudio pressionado!")

	if not player_de_audio:
		push_error("player_de_audio é null!")
		return

	if not player_de_audio.stream:
		push_error("Nenhum stream de áudio carregado!")
		return

	print("Iniciando reprodução do áudio...")

	# Não restaurar música de fundo aqui
	player_de_audio.play()
	print("Comando play executado")

func _on_bio_fato_audio_finished() -> void:
	print("Áudio terminado")
	# Remover a restauração da música de fundo
	# Deixamos vazio para evitar que a música volte

func _on_botao_continuar_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/bio_goods/scene/selecionar_quadro.tscn")

func _on_bio_fato_botao_continuar_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/bio_goods/scene/selecionar_quadro.tscn")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		_on_botao_audio_pressed()
