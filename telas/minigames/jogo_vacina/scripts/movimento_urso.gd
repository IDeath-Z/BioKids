extends AnimatedSprite2D

func _ready() -> void:
	position = Vector2(400.0,1300.0)

	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(385.0,900.0), 1.5)
