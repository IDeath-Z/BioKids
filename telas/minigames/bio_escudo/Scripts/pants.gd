extends Control

@onready var pants_sprite = $Sprite2D

# Keys
var pants_keys = []
var color_keys = []
var current_pants_index = 0
var current_color_index = 0

func _ready():
	set_sprite_keys()
	update_sprite()
	
# Set keys
func set_sprite_keys():
	pants_keys = GlobalBioEscudo.pants_collection.keys()

# Updates texture & modulate
func update_sprite():
	var current_sprite = pants_keys[current_pants_index]	
	if current_sprite == "none":
		pants_sprite.texture = null
	else:
		pants_sprite.texture = GlobalBioEscudo.pants_collection[current_sprite]
		pants_sprite.modulate = GlobalBioEscudo.pants_color_options[current_color_index]
	
	GlobalBioEscudo.selected_pants = current_sprite
	GlobalBioEscudo.selected_pants_color = GlobalBioEscudo.pants_color_options[current_color_index]	

# Change hair
func _on_collection_button_pressed():
	current_pants_index = (current_pants_index + 1) % pants_keys.size()
	update_sprite()

# Change hair color
func _on_color_button_pressed():
	current_color_index = (current_color_index + 1) % GlobalBioEscudo.pants_color_options.size()
	update_sprite()
