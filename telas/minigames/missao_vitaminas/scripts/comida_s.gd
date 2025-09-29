extends Area2D

@export var velocidade_queda: float = 200.0
@export var eh_saudavel: bool = true

var sprites_saudaveis: Array[Texture2D] = [
	preload("res://telas/minigames/missao_vitaminas/Imagens/Ali_Bons/ArrozFeijaoSalada.png"),
	preload("res://telas/minigames/missao_vitaminas/Imagens/Ali_Bons/Batata.png"),
	preload("res://telas/minigames/missao_vitaminas/Imagens/Ali_Bons/Brocolis.png"),
	preload("res://telas/minigames/missao_vitaminas/Imagens/Ali_Bons/Cenoura1.png"),
	preload("res://telas/minigames/missao_vitaminas/Imagens/Ali_Bons/Kiwi.png"),
	preload("res://telas/minigames/missao_vitaminas/Imagens/Ali_Bons/Laranja.png"),
	preload("res://telas/minigames/missao_vitaminas/Imagens/Ali_Bons/Maca.png"),
	preload("res://telas/minigames/missao_vitaminas/Imagens/Ali_Bons/OvoCozido.png"),
	preload("res://telas/minigames/missao_vitaminas/Imagens/Ali_Bons/Pimentao.png"),
	preload("res://telas/minigames/missao_vitaminas/Imagens/Ali_Bons/SucoNatural.png"),
	preload("res://telas/minigames/missao_vitaminas/Imagens/Ali_Bons/Tomate.png"),
	preload("res://telas/minigames/missao_vitaminas/Imagens/Ali_Bons/Uva.png")
]

var sprites_nao_saudaveis: Array[Texture2D] = [
	preload("res://telas/minigames/missao_vitaminas/Imagens/Ali_Ruins/Bala.png"),
	preload("res://telas/minigames/missao_vitaminas/Imagens/Ali_Ruins/CachorroQuente.png"),
	preload("res://telas/minigames/missao_vitaminas/Imagens/Ali_Ruins/Chocolate.png"),
	preload("res://telas/minigames/missao_vitaminas/Imagens/Ali_Ruins/Cookie.png"),
	preload("res://telas/minigames/missao_vitaminas/Imagens/Ali_Ruins/Coxinha.png"),
	preload("res://telas/minigames/missao_vitaminas/Imagens/Ali_Ruins/Donuts.png"),
	preload("res://telas/minigames/missao_vitaminas/Imagens/Ali_Ruins/Fritas.png"),
	preload("res://telas/minigames/missao_vitaminas/Imagens/Ali_Ruins/Hamburguer.png"),
	preload("res://telas/minigames/missao_vitaminas/Imagens/Ali_Ruins/Miojo.png"),
	preload("res://telas/minigames/missao_vitaminas/Imagens/Ali_Ruins/Pizza.png"),
	preload("res://telas/minigames/missao_vitaminas/Imagens/Ali_Ruins/Refrigerante.png"),
	preload("res://telas/minigames/missao_vitaminas/Imagens/Ali_Ruins/Salgadinho.png")
]

var sprite_index: int = 0

func _ready() -> void:
	add_to_group("comida")
	var sprite: Sprite2D = $Sprite2D
	if sprite:
		if eh_saudavel and sprite_index < sprites_saudaveis.size():
			sprite.texture = sprites_saudaveis[sprite_index]
		elif not eh_saudavel and sprite_index < sprites_nao_saudaveis.size():
			sprite.texture = sprites_nao_saudaveis[sprite_index]
		else:
			push_error("Índice de sprite inválido: " + str(sprite_index) + ", Saudável: " + str(eh_saudavel))
	else:
		push_error("Sprite2D não encontrado em comida!")

func _process(delta: float) -> void:
	position.y += velocidade_queda * delta
	if position.y > get_viewport_rect().size.y + 50:
		queue_free()
