@icon("res://images/icons/computer.svg")
extends Node


## beginning root of the cmd cycle
func cmd(command_string:String):	
	
	if command_string.is_empty():
		return
	
	if command_string.begins_with("/message"):
		message(command_string)
		return	
	if not command_string.begins_with("/"):
		chat(command_string)
		return
	
	command_string = command_string.to_lower()
	
	var command:ArgParser = ArgParser.new(command_string)

	
	match command.get_command():
		"/give":
			give(command)
		"/spawn":
			spawn(command)
		"/equip":
			equip(command)
		"/placement":
			placement(command)
		"/place":
			place(command)
		"/print_command":
			print_command(command)
		"/print_object":
			print_object(command)
		"/print_peer_id":
			print_peer_id()


## general chat messages
func chat(command:String):
	if not multiplayer.is_server():
		NetworkManager.send_server_chat_message.rpc_id(1, command)
	else:
		NetworkManager.server_chat_message.rpc(command)
		
## specific chat messages
func message(_command:String):
	pass	

## The main spawning command.
func spawn(command: ArgParser):
	var reject_message:String = "Something went wrong."
	var peer_id:int = multiplayer.get_unique_id()	
	var object_category = 0
	var object_id = 0
	
	object_category = command.get_argument("1")
	object_id = int(command.get_argument("2"))
	
	var player = Players.get_player_character(peer_id)
	if player == null:
		chat(reject_message)
		return	

	var spawn_node:Node3D = player.get_spawner_node()
	
	var default_pos = [spawn_node.global_position.x, spawn_node.global_position.y, spawn_node.global_position.z]
	var default_rot = [spawn_node.global_rotation_degrees.x, spawn_node.global_rotation_degrees.y, spawn_node.global_rotation_degrees.z]
	
	var pos = command.vector_from_array(command.get_argument("--p", default_pos))
	var rot = command.vector_from_array(command.get_argument("--r", default_rot))
	
	# now spawn object according to context / level
	match GameManager.current_level:
		GameManager.SCENES.WORLD:
			World.instance.spawn_object.rpc_id(1, object_category, object_id, pos, rot)
		GameManager.SCENES.PREFAB_EDITOR:
			PrefabEditor.instance.spawn_object(object_category, object_id, pos, rot)

## gives player a thing
func give(_command: ArgParser):
	pass

## equips a thing to the player
func equip(_command: ArgParser):
	pass

## places an object onto the ground
func place(_command: ArgParser):
	pass

func print_command(command:ArgParser):
	print(command)


	
## puts user into placement mode with a certain object
func placement(command: ArgParser):
	var reject_message:String = "Something went wrong."
	var peer_id:int = multiplayer.get_unique_id()	
	var object_category = 0
	var object_id = 0
	
	object_category = command.get_argument("1")
	object_id = int(command.get_argument("2"))
	
	var player = Players.get_player_character(peer_id)
	if player == null:
		chat(reject_message)
		return	
	
	player.enter_placement_mode(object_category, object_id)

func print_peer_id():
	UIConsole.instance.print_to_console(str(multiplayer.get_unique_id()))

func print_object(command:ArgParser):
	var print_string:String = ""

	var arg:Array = command.get_argument("--o")	
	if arg == null || arg.size() == 0:
		print("Command should appear as --o <object>.")
		print("/print_object --o players")
		print("/print_object --o loaded_mods")	
	
	match arg[0]:
		"players":
			print_string = JSON.stringify(Players.players)	
		"loaded_mods":
			print_string = JSON.stringify(ObjectIndex.index)	
	
	print(print_string)
	UIConsole.instance.print_to_console(print_string)
