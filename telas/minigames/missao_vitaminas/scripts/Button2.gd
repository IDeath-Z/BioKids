extends Button

func _ready():
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	connect("pressed", Callable(self, "_on_pressed"))

func _on_mouse_entered():
	scale = Vector2(0.21, 0.21)

func _on_mouse_exited():
	scale = Vector2(0.2, 0.2)

func _on_pressed():
	scale = Vector2(0.17, 0.17)
	await get_tree().create_timer(0.1).timeout
	scale = Vector2(0.2, 0.2)
