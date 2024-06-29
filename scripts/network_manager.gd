extends Node

# Autoload named Lobby

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

signal world_loaded
signal player_joined_world(peer_id)

const PORT = 27080
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20

var current_port := 0 #the port that the server launched on...

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info = {
	"steam_id": "0",
	"character_name":null,
	}

var players_loaded = 0

var current_world:Node3D = null

func initialize_network():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	world_loaded.connect(_on_world_loaded)
	player_joined_world.connect(_on_player_entered_world)

func join_game(address = "", port = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	if port.is_empty():
		port = PORT
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, int(PORT))
	if error:
		return error
	multiplayer.multiplayer_peer = peer

func create_game(port = "", announce_status:bool = false):	
	multiplayer.multiplayer_peer = null
	current_port = PORT
	if port.is_empty():
		port = PORT		
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(int(port), MAX_CONNECTIONS)
	var successful_port:int = int(port)	
	if error:
		for i in range(10):
			error = peer.create_server(int(port)+i, MAX_CONNECTIONS)
			if not error:
				successful_port = int(port)+i
				current_port = successful_port
				break	
	if error:		
		print(error)
		return error
	multiplayer.multiplayer_peer = peer	
	
	Players.add_player(multiplayer.get_unique_id(), Global.steam_id, Global.steam_username, Characters.get_currently_selected_character_name())
	register_player_to_server.rpc_id(1, Players.get_player(multiplayer.get_unique_id()))
		
	var status = "Created game at %s:%s"%[get_machines_ip_address(), successful_port]
	
	if announce_status:
		server_announce_status(status)
	send_server_greeting.rpc_id(1, status)

func create_single_player_game():
	create_game(str(PORT), true)
	server_announce_status("Closed server running...")

func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null

# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
@rpc("call_local", "reliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)

# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	pass
	'''
	Formerly:
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			$/root/Game.start_game()
			players_loaded = 0
	'''

# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):	
	server_announce_status("%s has joined the game."%id)

func _on_player_entered_world(peer_id):
	var player_name = Players.get_player_name(peer_id)
	var character_name = Players.get_player_character_name(peer_id)
	update_character_objects.rpc() #this is called here so that the newly spawned charcter object is added to player lists
	server_announce_status("%s (%s) has entered the world..."%[character_name, player_name], false)

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	player_connected.emit(new_player_id, new_player_info)

@rpc("authority", "call_local", "reliable")
func send_server_greeting(greeting:String):
	UIMain.display_status(greeting)

func _on_player_disconnected(id):
	var player_name = Players.get_player_name(id)
	var character_name = Players.get_player_character_name(id)
	server_announce_status("%s (%s) has left the game."%[character_name, player_name], false)
	Players.remove_player_by_peer_id(id)
	player_disconnected.emit(id)
	leave_game()	

#region onboarding

func _on_world_loaded():
	enter_world.rpc_id(1)
	var message = "Entering world... PORT %s"%str(current_port)
	UIConsole.instance.log_chat_to_console(multiplayer.get_unique_id(), message)

func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	player_connected.emit(peer_id, player_info)	
	player_info = populate_player_info(player_info)
	register_player_to_server.rpc_id(1, player_info)
	GameManager.change_scene(GameManager.SCENES.WORLD)

@rpc("any_peer", "call_local", "reliable")
func register_player_to_server(_player_info:Dictionary):
	if not multiplayer.is_server():
		return	
	var peer_id = multiplayer.get_remote_sender_id()		
	var steam_id = _player_info["steam_id"]
	var persona_name = _player_info["name"]
	var character_name = _player_info["character_name"]
	broadcast_add_player.rpc(peer_id, steam_id, persona_name, character_name)	
	
	send_server_greeting.rpc_id(peer_id, "Welcome to <SERVER_NAME>, %s"%persona_name)

## Upon new character spawning in, update the player dictionary
## with new character object info
@rpc("any_peer", "call_local", "reliable")
func update_character_objects():
	Players.update_character_objects()

#this is an RPC only
@rpc("authority", "call_local", "reliable")
func broadcast_add_player(peer_id, steam_id, persona_name, character_name):
	Players.add_player(peer_id, steam_id, persona_name, character_name)	

#this is an RPC_ID function only
@rpc("authority", "call_local", "reliable")
func add_player_from_server(peer_id, steam_id, persona_name, character_name):
	Players.add_player(peer_id, steam_id, persona_name, character_name)	

#endregion 
func _on_connected_fail():
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	Players.players.clear()
	server_disconnected.emit()

func leave_game(_peer_id:int = 0):
	pass

func _on_leave_game_pressed() -> void:
	remove_multiplayer_peer()
	if not multiplayer.is_server():
		return

func server_announce_status(status:String, print_only:bool = true):
	if not multiplayer.is_server():
		return
	print(status)
	if print_only:
		return
	server_chat_message.rpc_id(1, status)
	
func get_machines_ip_address():
	var ip_address :String

	if OS.has_feature("windows"):
		if OS.has_environment("COMPUTERNAME"):
			ip_address =  IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),IP.Type.TYPE_IPV4)
	elif OS.has_feature("x11"):
		if OS.has_environment("HOSTNAME"):
			ip_address =  IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),IP.Type.TYPE_IPV4)
	elif OS.has_feature("OSX"):
		if OS.has_environment("HOSTNAME"):
			ip_address =  IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),IP.Type.TYPE_IPV4)	
	return ip_address

## This information is provided locally by player.
func populate_player_info(_player_info:Dictionary) ->Dictionary:
	_player_info["steam_id"] = Global.steam_id
	_player_info["name"] = Global.steam_username
	_player_info["character_name"] = Characters.get_currently_selected_character_name()
	return _player_info

## communications
@rpc("any_peer", "call_remote", "reliable")
func send_server_chat_message(message:String):	
	if not multiplayer.is_server():
		return	
	var peer_id: int = multiplayer.get_remote_sender_id()
	player_info = Players.get_player_info_by_peer_id(peer_id)
	var player_message:String = format_chat_message(player_info, message)
	broadcast_chat_message_to_players.rpc(peer_id, player_message)

@rpc("authority", "call_local", "reliable")
func server_chat_message(message:String):	
	if not multiplayer.is_server():
		return		
	var server_message:String = format_server_message( message)
	broadcast_chat_message_to_players.rpc(1, server_message)

@rpc("any_peer", "call_local", "reliable")
func broadcast_chat_message_to_players(peer_id:int, message:String):	
	if UIChat.instance == null:
		return
	if UIConsole.instance == null:
		return
	UIChat.instance.recieve_chat_message_from_server(peer_id, message)
	UIConsole.instance.log_chat_to_console(peer_id, message)

func format_server_message(message:String) -> String:	
	var player_message:String = "[color=green]SERVER[/color]: %s"%[message]	
	return player_message

func format_chat_message(_player_info:Dictionary, message:String) -> String:
	var chat_name = _player_info["name"]
	if not _player_info["character_name"].is_empty():
		chat_name = _player_info["character_name"]		
	var player_message:String = "[color=yellow]%s[/color]: %s"%[chat_name, message]	
	return player_message

#region World related network ops

## Notifies the server that the player has entered the world.
## Called on _ready function in world.

func register_world(world:Node3D) ->void:
	current_world = world

func unregister_world()->void:
	current_world = null

@rpc("any_peer", "call_local", "reliable")
func enter_world() -> void:
	if not multiplayer.is_server():
		return
	var peer_id:int = multiplayer.get_remote_sender_id()
	
	current_world.do_player_spawn.rpc(peer_id)
#endregion
