extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_desenho_1_consultorio_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/bio_goods/scene/desenho1.tscn")


func _on_desenho_2__pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/bio_goods/scene/desenho2.tscn")


func _on_touch_screen_button_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/bio_goods/scene/desenho3.tscn")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/minigames/bio_goods/scene/home.tscn")
