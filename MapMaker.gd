extends Control

const cameraMoveSpeed = 3

var pressed
var press
var cameraTransform = Vector2.ZERO

var zoom_dir = 0
var frame_count = 0

func _process(delta):
	frame_count += 1
	
	var mouse_pos = get_viewport().get_mouse_position()
	if mouse_pos.x < 50:
		$Camera2D.position += Vector2(-cameraMoveSpeed, 0)
	elif mouse_pos.x > get_viewport().size.x - 50:
		$Camera2D.position += Vector2(cameraMoveSpeed, 0)
	if mouse_pos.y < 50:
		$Camera2D.position += Vector2(0, -cameraMoveSpeed)
	elif mouse_pos.y > get_viewport().size.y - 50:
		$Camera2D.position += Vector2(0, cameraMoveSpeed)
	
	mouse_pos = get_global_mouse_position()# - Vector2(64,64)
	if(pressed):
		var pos = Vector2(round(mouse_pos.x/32), round(mouse_pos.y/32))
		$TileMap.set_cellv(pos, press)
		$TileMap.update_bitmask_area(pos)
	
	
	$Camera2D.zoom += zoom_dir * Vector2(delta*5, delta*5)
	
	if(frame_count % 6 == 0):
		zoom_dir = 0
			


func _input(event):
	if event is InputEventMouseButton:
		pressed = event.is_pressed()
		#determines if should add or delete tile - left click should be 0 (add tile), right click -1
		if event.button_index == BUTTON_LEFT:
			press = 1
		elif event.button_index == BUTTON_RIGHT:
			press = -1
			
		elif event.button_index == BUTTON_WHEEL_UP:
			zoom_dir = -1
			# zoom out
		elif event.button_index == BUTTON_WHEEL_DOWN:
			zoom_dir = 1
		else:
			zoom_dir = 0



func _on_save_pressed():
	var name = $Camera2D/LineEdit.text
	if name != "":
		var file = File.new()
		file.open("res://levels/" + name + ".txt", File.WRITE)
		var content = ""
		for i in $TileMap.get_used_cells():
			content += str(i) + "\n"
		file.store_string(content)
		file.close()
		
func _on_back_pressed():
	get_tree().change_scene('res://main_menu.tscn')
