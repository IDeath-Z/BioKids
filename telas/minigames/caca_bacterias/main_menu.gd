extends Control

@onready var som_button = $Som # Referência ao botão som
@onready var background = $ColorRect
var screen_size

# Variáveis para guardar as configurações originais do jogo
var original_stretch_mode
var original_stretch_aspect

# 1. Defina o caminho para a nova música
const MUSICA_DA_CENA = preload("res://telas/minigames/caca_bacterias/assets/sounds/Walen-Gameboy-_freetouse.com_.wav")

func _ready():
	# Configura toggle som inicial (liga)
	AudioServer.set_bus_mute(0, false) # Bus 0 é master

	# CHAMA O AUTOLOAD (MusicPlayer) para tocar a música do minigame
	MusicPlayer.parar_para_evento_especial() # Para a música global e desliga o gerenciamento
	MusicPlayer.trocar_musica(MUSICA_DA_CENA) # Toca a nova música
	MusicPlayer.mudar_volume(0.8) # Opcional: Ajuste o volume, se necessário

func _on_iniciar_pressed():
	get_tree().change_scene_to_file("res://telas/minigames/caca_bacterias/scenes/HowToPlay.tscn")

func _on_como_jogar_pressed():
	get_tree().change_scene_to_file("res://telas/minigames/caca_bacterias/scenes/HowToPlay.tscn")

func _on_voltar_pressed() -> void:
	# ⭐️ FUNÇÃO CHAVE: Restaura o gerenciamento automático do Autoload
	MusicPlayer.restaurar_gerenciamento_automatico()

	# Volta para a cena de seleção (onde a música padrão deve tocar)
	get_tree().change_scene_to_file("res://telas/interface/selecaoMiniGame/tela_selecao_mini_game.tscn")
