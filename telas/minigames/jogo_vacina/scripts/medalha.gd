extends AnimatedSprite2D

func _ready() -> void:
	position = Vector2(369,-359)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(369,80), 1.5)
	
	await tween.finished
	play("medalha_conquista")
