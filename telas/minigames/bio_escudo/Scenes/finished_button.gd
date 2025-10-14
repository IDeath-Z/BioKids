extends TextureButton

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/interface/bioFato/bio_fato.tscn")
