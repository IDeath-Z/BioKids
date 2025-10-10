extends AnimatedSprite2D

func _ready() -> void:
	position = Vector2(369,-359)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(369,280), 1.1)
	
	await tween.finished
	play("medalha_conquista")
