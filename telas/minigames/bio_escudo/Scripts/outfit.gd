extends Control

@onready var outfit_sprite = $Sprite2D

# Keys
var outfit_keys = []
var color_keys = []
var current_outfit_index = 0
var current_color_index = 0

func _ready():
	set_sprite_keys()
	update_sprite()
	
# Set keys
func set_sprite_keys():
	outfit_keys = GlobalBioEscudo.outfit_collection.keys()

# Updates texture & modulate
func update_sprite():
	var current_sprite = outfit_keys[current_outfit_index]	
	outfit_sprite.texture = GlobalBioEscudo.outfit_collection[current_sprite]
	outfit_sprite.modulate = GlobalBioEscudo.color_options[current_color_index]
	
	GlobalBioEscudo.selected_outfit = current_sprite
	GlobalBioEscudo.selected_outfit_color = GlobalBioEscudo.color_options[current_color_index]	

# Change outfit
func _on_collection_button_pressed():
	current_outfit_index = (current_outfit_index + 1) % outfit_keys.size()
	update_sprite()

# Change color
func _on_color_button_pressed():
	current_color_index = (current_color_index + 1) % GlobalBioEscudo.color_options.size()
	update_sprite()
	
