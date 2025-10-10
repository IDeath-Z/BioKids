extends AnimatedSprite2D

func _ready() -> void:
	position = Vector2(380,1300.0)

	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(380.0,1050), 1.1)
