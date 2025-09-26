extends Node

# Collection of body sprites
var fur_collection = {
	"01" : preload("res://telas/minigames/bio_escudo/assets/urso.png")
}

# Collection of hair sprites
var pants_collection = {
	"none" : null,
	"01" : preload("res://telas/minigames/bio_escudo/assets/calca/calca.png"),
	"02" : preload("res://telas/minigames/bio_escudo/assets/calca/shorts.png"),
}

# Collection of outfit sprites
var outfit_collection = {
	"01" : preload("res://telas/minigames/bio_escudo/assets/camisa/camisa doc grey.png"),
	"02" : preload("res://telas/minigames/bio_escudo/assets/camisa/camisa.png"),
	"03" : preload("res://telas/minigames/bio_escudo/assets/camisa/jaleco_doc.png"),
}
# Collection of accessory sprites
var accessory_collection = {
	"none" : null,
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
	Color(0.4, 0.2, 0.1), # Brown
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

# Selected values
var selected_fur = ""
var selected_pants = ""
var selected_outfit = ""
var selected_accessory = ""
var selected_fur_color = ""
var selected_pants_color = ""
var selected_outfit_color = ""
var selected_accessory_color = ""
