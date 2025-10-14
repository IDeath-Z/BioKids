extends Camera2D

func _ready():
	var viewport_size = get_viewport_rect().size
	var target_size = Vector2(720, 1080)
	var aspect_ratio = viewport_size.x / viewport_size.y
	var target_aspect = target_size.x / target_size.y
	
	if aspect_ratio > target_aspect:
		zoom.x = viewport_size.y / target_size.y
		zoom.y = zoom.x
	else:
		zoom.y = viewport_size.x / target_size.x
		zoom.x = zoom.y
	
	# Center the camera on the scene
	position = target_size / 1000
