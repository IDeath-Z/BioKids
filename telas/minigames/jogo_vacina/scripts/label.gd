extends Label

func _ready() -> void:
	position = Vector2(-400.0,503)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(170,503), 1.5)
