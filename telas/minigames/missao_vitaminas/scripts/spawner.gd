extends Node2D

@onready var spawn_timer = $SpawnTimer
@onready var comida_saudavel = preload("res://telas/minigames/missao_vitaminas/Cenas/comida_saudavel.tscn")
@onready var comida_nao_saudavel = preload("res://telas/minigames/missao_vitaminas/Cenas/comida_nao_saudavel.tscn")

func _ready():
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout():
	var main = get_parent()
	if not main.game_started:
		return
	
	print("SpawnTimer disparado, game_started: ", main.game_started)
	
	var comida_aleatoria
	
	if randf() < 0.5:
		comida_aleatoria = comida_saudavel.instantiate()
		comida_aleatoria.sprite_index = main.current_saudavel_index
	else:
		comida_aleatoria = comida_nao_saudavel.instantiate()
		comida_aleatoria.sprite_index = main.current_nao_saudavel_index
	
	comida_aleatoria.velocidade_queda = main.current_fall_speed
	var randomize_x = randf_range(10, get_viewport_rect().size.x - 10)
	comida_aleatoria.position = Vector2(randomize_x, 0)
	add_child(comida_aleatoria)
	print("Spawnando comida com índice: ", comida_aleatoria.sprite_index, " e velocidade: ", main.current_fall_speed)
