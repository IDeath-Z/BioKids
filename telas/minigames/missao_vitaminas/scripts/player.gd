extends CharacterBody2D

@export var velocidade: float = 240.0
var anim_sprite: AnimatedSprite2D
var screen_width: float
var pontos: int = 0
var vidas: int = 3
@onready var pontos_label = get_node("/root/Main/UILayer/PontosLabel") if has_node("/root/Main/UILayer/PontosLabel") else null
@onready var vidas_label = get_node("/root/Main/UILayer/VidasLabel") if has_node("/root/Main/UILayer/VidasLabel") else null
@onready var pickup_sound = get_node("/root/Main/UILayer/PickupSound") if has_node("/root/Main/UILayer/PickupSound") else null
@onready var damage_sound = get_node("/root/Main/UILayer/DamageSound") if has_node("/root/Main/UILayer/DamageSound") else null
@onready var game_over_sound = get_node("/root/Main/UILayer/GameOverSound") if has_node("/root/Main/UILayer/GameOverSound") else null
@onready var main_node = get_node("/root/Main")
signal score_changed(new_score)

func _ready():
	anim_sprite = $AnimatedSprite2D
	anim_sprite.play("idle")
	screen_width = get_viewport_rect().size.x
	$Hitbox.area_entered.connect(_on_hitbox_area_entered)
	if pickup_sound:
		print("PickupSound encontrado, stream: ", pickup_sound.stream.resource_path if pickup_sound.stream else "Nenhum stream atribuído")
	else:
		print("Erro: PickupSound não encontrado!")
	if damage_sound:
		print("DamageSound encontrado, stream: ", damage_sound.stream.resource_path if damage_sound.stream else "Nenhum stream atribuído")
	else:
		print("Erro: DamageSound não encontrado!")
	if game_over_sound:
		print("GameOverSound encontrado, stream: ", game_over_sound.stream.resource_path if game_over_sound.stream else "Nenhum stream atribuído")
	else:
		print("Erro: GameOverSound não encontrado!")

func _process(delta):
	if not main_node.game_started:
		return
	var direcao = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		direcao.x += 1
	if Input.is_action_pressed("ui_left"):
		direcao.x -= 1

	if direcao != Vector2.ZERO:
		direcao = direcao.normalized()
		anim_sprite.play("walk")
	else:
		anim_sprite.play("idle")

	position += direcao * velocidade * delta

	if direcao.x != 0:
		anim_sprite.flip_h = direcao.x < 0

	position.x = clamp(position.x, 0, screen_width)

func _on_hitbox_area_entered(area):
	var main = main_node
	if area.is_in_group("comida"):
		if area.eh_saudavel:
			pontos += 10
			if pickup_sound:
				pickup_sound.play()
				print("Som de coleta saudável tocado para pontos: ", pontos)
			else:
				print("Erro: PickupSound não encontrado ao tentar tocar!")
		else:
			vidas -= 1
			if damage_sound:
				damage_sound.play()
				print("Som de dano tocado, vidas restantes: ", vidas)
			else:
				print("Erro: DamageSound não encontrado ao tentar tocar!")
			if vidas <= 0:
				if vidas_label:
					vidas_label.text = "Vidas: 0"
				if game_over_sound:
					game_over_sound.play()
					print("Som de Game Over tocado")
				else:
					print("Erro: GameOverSound não encontrado ao tentar tocar!")
				main.show_game_over()
			else:
				if vidas_label:
					vidas_label.text = "Vidas: " + str(vidas)
		area.queue_free()
	
		emit_signal("score_changed", pontos)
		if pontos_label:
			pontos_label.text = "Pontos: " + str(pontos)
