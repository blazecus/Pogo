# This source code is provided as reference/companion material for the Godot Multiplayer Setup tutorial
# that can be freely found at http://kehomsforge.com and should not be commercialized
# in any form. It should remain free!
#
# By Yuri Sarudiansky

extends CanvasLayer


func _ready():
	network.connect("server_created", self, "_on_ready_to_play")
	network.connect("join_success", self, "_on_ready_to_play")
	network.connect("join_fail", self, "_on_join_fail")
	
	var dir = Directory.new()
	dir.open("res://levels/")
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file =="":
			break
		elif not file.begins_with("."):
			$MapMaker/ItemList.add_item(file)


func set_player_info():
	if (!$PanelPlayer/txtPlayerName.text.empty()):
		gamestate.player_info.name = $PanelPlayer/txtPlayerName.text
	gamestate.player_info.char_color = $PanelPlayer/btColor.color


func _on_btCreate_pressed():
	# Properly set the local player information
	set_player_info()
	
	# Gather values from the GUI and fill the network.server_info dictionary
	if (!$PanelHost/txtServerName.text.empty()):
		network.server_info.name = $PanelHost/txtServerName.text
	network.server_info.max_players = int($PanelHost/txtMaxPlayers.value)
	network.server_info.used_port = int($PanelHost/txtServerPort.text)
	if len($MapMaker/ItemList.get_selected_items()) > 0:
		network.server_info.current_map = $MapMaker/ItemList.get_item_text($MapMaker/ItemList.get_selected_items()[0])
	
	var file = File.new()
	file.open("res://levels/" + network.server_info.current_map, File.READ)
	var content = file.get_as_text()
	file.close()
	network.server_info.map_content = content
	# And create the server, using the function previously added into the code
	network.create_server()


func _on_btJoin_pressed():
	# Properly set the local player information
	set_player_info()
	
	var port = int($PanelJoin/txtJoinPort.text)
	var ip = $PanelJoin/txtJoinIP.text
	network.join_server(ip, port)
	
	var file = File.new()
	
	file.open("res://levels/" + network.server_info.current_map, file.WRITE)
	file.store_string(network.server_info.map_content)
	file.close()


func _on_ready_to_play():
	get_tree().change_scene("res://Game.tscn")


func _on_join_fail():
	print("Failed to join server")



func _on_mmEnter_pressed():
	get_tree().change_scene("res://MapMaker.tscn")
