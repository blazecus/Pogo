extends Camera2D

func _process(delta):
	var size = get_viewport().size
	var corner = -size/2
	$LineEdit.rect_position = Vector2(corner.x + size.x-256, corner.y + 32)
	$save.rect_position = Vector2(corner.x + size.x-96, corner.y + 32)
	$back.rect_position = Vector2(corner.x + 32, corner.y + 32)
