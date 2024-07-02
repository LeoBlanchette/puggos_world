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
		"/save":
			do_save(command)
		"/load":
			do_load(command)
		"/clear":
			do_clear(command)
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
		"/kick":
			kick(command)		
		"/print_command":
			print_command(command)
		"/print_object":
			print_object(command)
		"/print_peer_id":
			print_peer_id()
		# MODDING
		"/upload_mod":
			upload_mod(command)
		"/update_mod":
			update_mod(command)

#region level editing 

func do_save(command:ArgParser):
	var file_name = command.get_argument("1", null)
	if file_name==null:
		print_to_console("Please save with a file name...")
		print_to_console("Example: /save some_prefab_name")
		return
	
	match GameManager.current_level:
		GameManager.SCENES.PREFAB_EDITOR:
			Save.save_prefab_editor(file_name)
		GameManager.SCENES.WORLD_EDITOR:
			Save.save_world_editor()
		GameManager.SCENES.WORLD:
			Save.save_world()

func do_load(command:ArgParser):
	var file_name = command.get_argument("1", null)
	if file_name==null:
		print_to_console("Please load by a file name...")
		print_to_console("Example: /load some_prefab_name")
		return
	match GameManager.current_level:
		GameManager.SCENES.PREFAB_EDITOR:
			Save.load_prefab_editor(file_name)
		GameManager.SCENES.WORLD_EDITOR:
			Save.load_world_editor()
		GameManager.SCENES.WORLD:
			Save.load_world()

func do_clear(command:ArgParser):
	pass

#endregion

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

func kick(command:ArgParser):
	var user:String = ""
	var m:Array = command.get_argument("--m", "You were kicked from the server.".split(" "))
	var message:String = ""
	command.print_arguments()
	for word in m:
		message += "%s "%word

	if command.get_argument("1") != null:
		user = command.get_argument("1")
		NetworkManager.drop_user(user, message)

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
		print_to_console("Command should appear as --o <object>.")
		print_to_console("/print_object --o players")
		print_to_console("/print_object --o loaded_mods")	
	
	match arg[0]:
		"players":
			print_string = JSON.stringify(Players.players)	
		"loaded_mods":
			print_string = JSON.stringify(ObjectIndex.index)	
	
	print(print_string)
	print_to_console(print_string)

func print_to_console(print_string:String)->void:
	UIConsole.instance.print_to_console(print_string)

func upload_mod(command:ArgParser):
	Workshop.register_mod("HELLOWORLD")

func update_mod(command:ArgParser):
	pass
