extends Node

var player_info = {
	name = "Player",                   # How this player will be shown within the GUI
	net_id = 1,                        # By default everyone receives "server" ID
	actor_path = "res://Player/Player.tscn",  # The class used to represent the player in the game world
	char_color = Color(1, 1, 1),       # By default don't modulate the icon color
}

var spawned_bots = 0
var bot_info = {}


func _ready():
	randomize()
	
	# Initialize the bot list
	for id in range(1, 16):
		bot_info[id] = { name = "Bot_" + str(id), actor_path = "res://bot.tscn" }

