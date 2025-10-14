extends TextureButton

@onready var tutorial = $"../TutorialPopup"

func _on_pressed():
	if GlobalBioEscudo.selected_outfit == GlobalBioEscudo.camisa_certa \
	and GlobalBioEscudo.selected_pants == GlobalBioEscudo.calca_certa \
	and GlobalBioEscudo.selected_accessory == GlobalBioEscudo.acessorio_certo:
		# ✅ Acertou tudo
		if tutorial:
			await tutorial.show_success_and_continue()
	else:
		# ❌ Errou → mostra erro correspondente
		if tutorial:
			if GlobalBioEscudo.selected_outfit != GlobalBioEscudo.camisa_certa:
				tutorial.on_player_error("camisa")
			elif GlobalBioEscudo.selected_pants != GlobalBioEscudo.calca_certa:
				tutorial.on_player_error("pants")
			else:
				tutorial.on_player_error("epi")
