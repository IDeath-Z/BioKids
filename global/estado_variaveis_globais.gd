extends Node

@onready var urso_saiu_tela_menu = false
@onready var musica_ligada = true

var in_minigame_vitaminas: bool = false  # Novo: flag para saber se já estamos no minigame
var minigame_vitaminas_music_on: bool = false  # Novo: armazena o estado original da música para este minigame específico

var in_minigame_vacina: bool = false
var minigame_vacina_music_on: bool = false

var in_menu_music = true
