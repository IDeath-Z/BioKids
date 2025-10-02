extends TextureButton

@onready var erro_sprite = $"../ErroSprite"

func _ready():
	# Garantir que o sprite de erro esteja inicialmente invisível
	if erro_sprite:
		erro_sprite.visible = false

func _on_pressed():
	# Verificar se a combinação está correta usando GlobalBioEscudo
	if (GlobalBioEscudo.selected_outfit == GlobalBioEscudo.camisa_certa and 
		GlobalBioEscudo.selected_pants == GlobalBioEscudo.calca_certa and 
		GlobalBioEscudo.selected_accessory == GlobalBioEscudo.acessorio_certo):
		# Combinação correta: redirecionar para a cena
		get_tree().change_scene_to_file("res://telas/minigames/bio_escudo/Scenes/bioFato/bio_fato_EPIs.tscn")
	else:
		# Combinação errada: mostrar sprite de erro temporariamente
		if erro_sprite:
			erro_sprite.visible = true
			# Iniciar um timer para esconder o sprite após 2 segundos
			await get_tree().create_timer(2.0).timeout
			erro_sprite.visible = false
		print("Equipamentos errados!")
