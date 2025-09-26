extends Control

@onready var fur_sprite = $Sprite2D

var fur_keys = []
var color_keys = []
var current_fur_index = 0
var current_color_index = 0

func _ready():
	set_sprite_keys()
	update_sprite()
	
func set_sprite_keys():
	fur_keys = Global.fur_collection.keys()
	
func update_sprite():
	var current_sprite = fur_keys[current_fur_index]
	fur_sprite.texture = Global.fur_collection[current_sprite]
	fur_sprite.modulate = Global.fur_color_options[current_color_index]
	
	Global.selected_fur = current_sprite
	Global.selected_fur_color = Global.fur_color_options[current_color_index]


func _on_collection_button_pressed() -> void:
	current_fur_index = (current_fur_index +1) % fur_keys.size()
	update_sprite()


func _on_color_button_pressed() -> void:
	current_color_index = (current_color_index +1 ) % Global.fur_color_options.size()
	update_sprite()
