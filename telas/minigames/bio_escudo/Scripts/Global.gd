extends Node

# Coleção de sprites de pelos do ursinho
var fur_collection = {
	"01" : preload("res://telas/minigames/bio_escudo/assets/urso.png")
}

# Coleção de sprites de calça
var pants_collection = {
	"none" : null,
	"01" : preload("res://telas/minigames/bio_escudo/assets/calca/calca.png"),
	"02" : preload("res://telas/minigames/bio_escudo/assets/calca/shorts.png"),
}

# Coleção de sprites de camisas
var outfit_collection = {
	"none" : null,
	"01" : preload("res://telas/minigames/bio_escudo/assets/camisa/camisa doc grey.png"),
	"02" : preload("res://telas/minigames/bio_escudo/assets/camisa/camisa.png"),
	"03" : preload("res://telas/minigames/bio_escudo/assets/camisa/jaleco_doc.png"),
}

# Coleção de sprites de acessórios
var accessory_collection = {
	"none" : null,
	"01" : preload("res://telas/minigames/bio_escudo/assets/acess/chapeu_cangac.aces.png"),
	"02" : preload("res://telas/minigames/bio_escudo/assets/acess/vac.acess.png"),
	"03" : preload("res://telas/minigames/bio_escudo/assets/acess/doctor_equip.acess.png"),
	"04" : preload("res://telas/minigames/bio_escudo/assets/acess/mask01.acess.png"),
	"05" : preload("res://telas/minigames/bio_escudo/assets/acess/mask01.acess.png"),
}

# Fur Colors
var fur_color_options = [
	Color(1, 1, 1), # Default
	Color(0.96, 0.80, 0.69), # Light Skin
	Color(0.72, 0.54, 0.39), # Medium Skin
	Color(0.45, 0.34, 0.27), # Brown Skin
]

# Pants Colors
var pants_color_options = [
	Color(1, 1, 1), # Default
	Color(1.05, 1.05, 1.05), 
	Color(0.95, 0.95, 0.95), 
	Color(0.9, 0.95, 1.0), 
]

# Outfit & accessory colors
var color_options = [
	Color(1, 1, 1), # Default
	Color(1.0, 0.95, 0.9),
	Color(1.05, 1.05, 1.05), 
	Color(1.0, 0.97, 0.93), 
	Color(0.95, 0.95, 0.95),
	Color(0.9, 0.95, 1.0), 
]

# Seleções atuais
var selected_fur = ""
var selected_pants = ""
var selected_outfit = ""
var selected_accessory = ""
var selected_fur_color = ""
var selected_pants_color = ""
var selected_outfit_color = ""
var selected_accessory_color = ""

# roupas atuais
var camisa_atual = ""
var calca_atual = ""
var acessorio_atual = ""

# Definindo a combinação correta
var camisa_certa = "03"   # Jaleco médico
var calca_certa = "01"    # Calça médico
var acessorio_certo = "03" # Equipamento médico
