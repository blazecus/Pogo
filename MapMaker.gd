extends Control

const cameraMoveSpeed = 3

var pressed
var press
var cameraTransform = Vector2.ZERO

func _process(delta):
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
		$TileMap.set_cell(floor(mouse_pos.x/64), floor(mouse_pos.y/64), press)



func _input(event):
	if event is InputEventMouseButton:
		pressed = event.is_pressed()
		#determines if should add or delete tile - left click should be 0 (add tile), right click -1
		press = int(event.button_index == BUTTON_LEFT) - 1


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
