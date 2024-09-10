@icon("res://images/icons/computer.svg")
extends Node

var history:Array[String] = []
var history_current_index:int = 0
## beginning root of the cmd cycle
func cmd(command_string:String):	
	
	command_string = detect_cmd(command_string)
	
	if command_string.is_empty():
		print_to_console(" ") ## For formatting.
		return
	
	if not command_string.begins_with("/"):
		chat(command_string)
		return

	add_cmd_history(command_string)
	
	var command:ArgParser = ArgParser.new(command_string)
	
	match command.get_command():
		"/help":
			help(command)
		"/unilink_info":
			unilink_info(command)
		"/whoami":
			whoami(command)
		"/whois":
			whois(command)
		"/list_players":
			list_players(command)
		"/print_mod_dir":
			print_mod_dir(command)
		"/save":
			do_save(command)
		"/load":
			do_load(command)
		"/load_prefab":
			load_prefab(command)
		"/clear":
			do_clear(command)
		"/give":
			give(command)
		"/play_animation":
			play_animation(command)
		"/spawn":
			spawn(command)
		"/interact":
			interact(command)
		"/teleport":
			teleport(command)
		"/t": #teleport shorthand
			teleport(command)
		"/set_personality":
			set_personality(command)
		"/equip":
			equip(command)
		"/unequip":
			unequip(command)
		"/list_slots":
			list_slots(command)
		"/list_equipped":
			list_equipped(command)
		"/print_index":
			print_index(command)
		"/placement":
			placement(command)
		"/place":
			place(command)
		"/kick":
			kick(command)		
		"/print_object_meta":
			print_object_meta(command)
		"/print_object":
			print_object(command)
		"/print_peer_id":
			print_peer_id(command)
		# MODDING
		"/upload_mod":
			upload_mod(command)
		"/update_mod":
			update_mod(command)
		"/ip":
			ip(command)
		"/shutdown":
			shutdown(command)
		"/server_info":
			server_info(command)
		"/rick":
			rick(command)
		#MINI OS
		"/ls":
			ls(command)
		"/pwd":
			pwd(command)
		"/cd":
			cd(command)
		_:
			print_to_console("[color=red]Command not recognized.[/color]")
			print_to_console("[color=orange]type [color=green][b]/help[/b][/color] to get a list of commands.[/color]")

#region level editing 

func print_help_doc(command:String)->void:

	const DOCS:String = "res://docs/cmd/"
	var file_path:String = "%s%s.txt"%[DOCS, command]
	if not FileAccess.file_exists(file_path):
		return
	var file = FileAccess.open(file_path, FileAccess.READ)
	while not file.eof_reached():
		var line:String = file.get_line()
		print_to_console(line)

	
func help(command:ArgParser):
	var commands:Dictionary = {
		"/help":"Prints a list of commands and a brief description of what they do.",
		"/unilink_info":"Prints out UniLink info.",
		"/whoami":"Shows your player information.",
		"/whois":"Shows information on a player based on Steam persona name.",
		"/ls":"Lists items in a given res://mods/* directory.",
		"/pwd":"Prints the Present Working Directory.",
		"/cd":"Change Directory to the specified folder. Example: cd puggos_world",
		"/list_players":"Lists information of player currently in game.",
		"/save":"Saves a game / map / prefab state.",
		"/load":"Loads level such as World, Editor, or Prefab.",
		"/load_prefab":"Loads a prefab while in the world editor.",
		"/clear":"Clears the console.",
		"/give":"Gives player an item. Not operative yet.",
		"/play_animation":"Plays an animation on the character.",
		"/spawn":"Spawns an object.",
		"/interact":"Interacts with an object. Typically called by game, not console.",
		"/teleport":"Teleports a player based on X,Y,Z coordinates supplied.",
		"/t":"Shortcut for the /teleport command.",
		"/set_personality":"Sets the personality (long idle) of the character. /set_personality --help for for information on this system.",
		"/equip":"Equips an item.",
		"/unequip":"Unequips a slot, removing the item in the slot.",
		"/list_slots":"Lists all character slots with their descriptions.",
		"/list_equipped":"Lists all items equipped on character. Returns a dictionary {'slot_<num>':<id>} if used in code.",
		"/placement":"Puts user into placement mode, for placing an object such as modular building part.",
		"/place":"Places an item.",
		"/print_mod_dir": "Gets the directory of a mod. Returns a string when used in code. Example: /get_mod_dir animations 3",
		"/kick":"Kick a player by Steam persona name.",
		"/print_index":"Prints the entire item index loaded into the game.",
		"/print_object":"Prints the status / info of an important object in the game. For modder use.",
		"/print_peer_id":"Prints your peer id.",
		"/print_object_meta":"Prints the meta data on a mod object.",
		"/upload_mod":"Uploads a new mod to steam based on path supplied to it's root folder.",
		"/update_mod":"Uploads / Updates a mod to steam based on path supplied to it's root folder. (Not yet working.)",
		"/ip":"Prints the IP Address to the console.",
		"/shutdown":"Quits the application. ",
		"/server_info":"Prints out server information. Ip Address, Port, Etc.",
		"/rick": "For when you are tired of reading documentation"
	}
		
	var cmd_:String = command.get_first_argument().strip_edges().to_lower()
	
	if cmd_ == "/help":
		print_to_console("[color=green]Available Commands:[/color]")
		for key in commands:
			print_to_console("[color=green]%s[/color]: %s"%[key, commands[key]])
		print_to_console(" ")
		print_to_console("type [color=green]/<command> --help[/color] to find more on the given command.")
		return
		
	if not command.get_first_argument().is_empty():
		var key:String = cmd_
		if commands.has(key):		
			
			print_to_console("[color=green]%s[/color]: %s"%[key, commands[key]])
			print_help_doc(key)


func is_help_request(command:ArgParser)->bool:
	return command.arguments["argument_string"].contains("--help")


func print_player_information_to_console(peer_id):
	var player = Players.get_player(peer_id)
	if player == null:
		print_to_console("player == null")
		return
	for key in player:
		print_to_console("[color=green]%s:[/color] %s"%[str(key), str(player[key])])


func unilink_info(_command:ArgParser):
	print_help_doc("unilink_info")


func whois(command:ArgParser):
	if is_help_request(command):
		help(command)
		return
	var reject:String = "Cannot find that player..."
	var player_name:String = command.get_argument("1", "")
	if player_name.is_empty():
		print_to_console(reject)
	var peer_id:int = Players.get_peer_id_by_persona_name(player_name)
	if peer_id == 0:
		print_to_console(reject)
	print_player_information_to_console(peer_id)


func whoami(command:ArgParser = null):
	if is_help_request(command):
		help(command)
		return
	var peer_id:int = multiplayer.get_unique_id()
	print_player_information_to_console(peer_id)

func print_mod_dir(command:ArgParser)->String:
	if is_help_request(command):
		help(command)
		return ""
	
	if command.get_argument("1") == null:
		help(command)
		return ""
	if command.get_argument("2") == null:
		help(command)
		return ""
	
	var dir:String = ObjectIndex.object_index.get_mod_dir(command.get_argument("1"), int(command.get_argument("2")))
	if dir.is_empty():
		print_error_to_console("ERROR CODE #WTF: Recieved null value. Requested non-existent object or wrong input or incompetent user.")
		return ""
	print_to_console(dir)
	return dir


func list_players(command:ArgParser = null):
	if is_help_request(command):
		help(command)
		return
	for peer_id in Players.players:
		print_player_information_to_console(peer_id)
		print_to_console("---- ---- ---- ---- ---- ---- ")

func do_save(command:ArgParser):
	if is_help_request(command):
		help(command)
		return
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

func load_prefab(command:ArgParser):
	if is_help_request(command):
		help(command)
		return
	if GameManager.current_level == GameManager.SCENES.PREFAB_EDITOR:
		print_to_console("When using the Prefab Editor, use \"load\" instead. \"load_prefab\" is for World and World Editor use.")
		return
	var file_name = command.get_argument("1", null)
	if file_name==null:
		print_to_console("Please load by a file name...")
		print_to_console("Example: /load some_prefab_name")
		return
	Save.load_prefab(file_name)

func do_load(command:ArgParser):
	if is_help_request(command):
		help(command)
		return
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
	if is_help_request(command):
		help(command)
	UIConsole.instance.clear()

#endregion

## general chat messages
func chat(command:String):
	if not multiplayer.is_server():
		NetworkManager.send_server_chat_message.rpc_id(1, command)
	else:
		NetworkManager.server_chat_message.rpc(command)
		
## specific chat messages
func message(command:ArgParser):
	if is_help_request(command):
		help(command)
		return

## The main spawning command.
func spawn(command: ArgParser):
	if is_help_request(command):
		help(command)
		return
	var reject_message:String = "Something went wrong."
	var peer_id:int = multiplayer.get_unique_id()	
	var object_category = 0
	var object_id = 0
	
	if command.get_argument("1") == null:
		help(command)
		return
	if command.get_argument("2") == null:
		help(command)
		return
		
	object_category = command.get_argument("1")
	object_id = int(command.get_argument("2"))
	var player = Players.get_player_character(peer_id)
	if player == null:
		chat(reject_message)
		return	

	var spawn_node:Node3D = player.get_spawner_node()
	
	var default_pos = [spawn_node.global_position.x, spawn_node.global_position.y, spawn_node.global_position.z]
	var default_rot = [spawn_node.global_rotation_degrees.x, spawn_node.global_rotation_degrees.y, spawn_node.global_rotation_degrees.z]
	
	var pos = ArgParser.vector_from_array(command.get_argument("--p", default_pos))
	var rot = ArgParser.vector_from_array(command.get_argument("--r", default_rot))
	
	# now spawn object according to context / level
	match GameManager.current_level:
		GameManager.SCENES.WORLD:
			World.instance.spawn_object.rpc_id(1, object_category, object_id, pos, rot)
		GameManager.SCENES.WORLD_EDITOR:
			WorldEditor.instance.spawn_object(object_category, object_id, pos, rot)
		GameManager.SCENES.PREFAB_EDITOR:
			PrefabEditor.instance.spawn_object(object_category, object_id, pos, rot)

## Basic interaction.
func interact(command:ArgParser):
	if is_help_request(command):
		help(command)
		return
	var instance_id_string = command.get_argument("1")
	if instance_id_string == null:
		return
	var instance_id = int(instance_id_string)
	
	var ob = instance_from_id(instance_id)
	if ob is not Node3D:
		return
	if World.instance == null:
		return
	World.instance.do_player_interaction.rpc_id(1, ob.get_path())

func teleport(command:ArgParser):
	if is_help_request(command):
		help(command)
		return
	var reject_message:String = "Something went wrong."
	var peer_id:int = multiplayer.get_unique_id()	

	var player = Players.get_player_character(peer_id)
	if player == null:
		chat(reject_message)
		return	
	if command.get_argument("--p", "").is_empty():
		help(command)
		return
	var pos = ArgParser.vector_from_array(command.get_argument("--p", player.global_position))
	player.global_position = pos
	
## gives player a thing
func give(command: ArgParser):
	if is_help_request(command):
		help(command)
		return

## plays an animation
func play_animation(command: ArgParser):
	if is_help_request(command):
		help(command)
		return

## Sets the character personality, the personality being an animation id
## that has meta "personality" as true.
func set_personality(command:ArgParser):
	if is_help_request(command):
		help(command)
		return
	var reject_message:String = "Something went wrong."
	var peer_id:int = multiplayer.get_unique_id()	
	var personality_id = "0"
	
	personality_id = command.get_argument("1", personality_id).to_int()
	if personality_id == 0:
		print(reject_message)
		return 

	# target player if specified 
	var target_player:String = ""	
	if command != null:
		if command.has_argument("--pid"):
			target_player = command.get_argument("--pid", str(peer_id))[0]
	if not target_player.is_empty():
		peer_id = target_player.to_int()
	# end taret player if specified 

	var player:Player = Players.get_player_character(peer_id)
	if player == null:
		chat(reject_message)
		return
	
	if not target_player.is_empty():
		set_personality_remote.rpc_id(peer_id, personality_id)
	else:
		player.personality_id = personality_id

@rpc("authority", "call_local", "reliable")
func set_personality_remote(personality_id):
	var peer_id:int = multiplayer.get_unique_id()
	var player:Player = Players.get_player_character(peer_id)
	player.personality_id = personality_id

## equips a thing to the player
func equip(command: ArgParser):
	if is_help_request(command):
		help(command)
		return
	var reject_message:String = "Something went wrong."
	var peer_id:int = multiplayer.get_unique_id()	
	var object_id = "0"
	
	object_id = command.get_argument("1", object_id).to_int()
	if object_id == 0:
		print(reject_message)
		return 
	
	# target player if specified 
	var target_player:String = ""	
	if command != null:
		if command.has_argument("--pid"):
			target_player = command.get_argument("--pid", str(peer_id))[0]
	if not target_player.is_empty():
		peer_id = target_player.to_int()
	# end taret player if specified 
	
	var player:Player = Players.get_player_character(peer_id)
	
	if player == null:
		chat(reject_message)
		return
	if not target_player.is_empty():
		equip_remote.rpc_id(peer_id, object_id)
	else:
		player.equip(object_id)

## For the server to call equip actions to clients...
@rpc("authority", "call_local", "reliable")
func equip_remote(id:int):
	multiplayer.get_unique_id()
	var player:Player = Players.get_player_character(multiplayer.get_unique_id())
	player.equip(id)

func print_index(command:ArgParser)->void:
	if is_help_request(command):
		help(command)
		return
	for key in ObjectIndex.index:
		for id in ObjectIndex.index[key]:
			var ob:Node = ObjectIndex.index[key][id]
			var mod_name:String = ob.get_meta("name", "* not named")
			
			var basic_print:String = "%s: %s [%s]"%[key, str(id), mod_name]
			var console_print:String = "[color=green]%s:[/color] [color=yellow]%s[/color] [ %s ]"%[key, str(id), mod_name]
			print(basic_print)
			print_to_console(console_print)

func list_equipped(command:ArgParser = null)->Dictionary:
	if command != null: #If null, it is used from code and not a text command.
		if is_help_request(command):
			help(command)
			return {}
	var reject_message:String = "Something went wrong."
		
	var peer_id:int = multiplayer.get_unique_id()	
	var target_player:String = ""
	if command != null:
		target_player = command.get_second_argument().strip_edges()
	if not target_player.is_empty():
		peer_id = Players.get_peer_id_by_persona_name(target_player)
	var player:Player = Players.get_player_character(peer_id)
	if player == null:
		print_to_console(reject_message)
		return	 {}
	var player_name:String = Players.get_player_name(peer_id)
	print_to_console(" ")
	print_to_console("[color=orange]%s[/color] equipped items: "%player_name)
	var equipped:Dictionary = {}
	for slot_number:int in range(0, 40):
		var slot = "slot_%s"%str(slot_number)
		var id:int = player.get(slot)
		if ObjectIndex.index.has("items"):
			if ObjectIndex.index["items"].has(id):
				var ob:Node  = ObjectIndex.index["items"][id]
				var mod_name:String = ob.get_meta("name", "* no name")
				print_to_console("[color=green]%s[/color]: [color=yellow]%s[/color]    [color=gray][ %s ][/color]"%[slot, str(id), mod_name])
				equipped[slot]=id
	return equipped
	
func list_slots(command:ArgParser = null):
	if is_help_request(command):
		help(command)
		return
	for key in CharacterAppearance.Equippable.keys():
		var slot_info:String ="[color=yellow]%s[/color]: %s"%[key, CharacterAppearance.get_slot_description(CharacterAppearance.Equippable.get(key))]
		UIConsole.instance.print_to_console(slot_info)

## unequips a thing to the player
func unequip(command: ArgParser):
	if is_help_request(command):
		help(command)
		return
	var reject_message:String = "Something went wrong."
	var peer_id:int = multiplayer.get_unique_id()	
	var slot_number = "-1"

	# target player if specified 
	var target_player:String = ""	
	if command != null:
		if command.has_argument("--pid"):
			target_player = command.get_argument("--pid", str(peer_id))[0]
	if not target_player.is_empty():
		peer_id = target_player.to_int()
	# end taret player if specified 

	slot_number = command.get_argument("1", slot_number).to_int()
	if slot_number == -1:
		print(reject_message)
		return 

	var player:Player = Players.get_player_character(peer_id)
	if player == null:
		chat(reject_message)
		return
	
	if not range(0, 39).has(slot_number):
		chat(reject_message)
		return
	
	if not target_player.is_empty():
		unequip_remote.rpc_id(peer_id, slot_number)
	else:
		player.unequip("slot_%s"%slot_number)

@rpc("authority", "call_local", "reliable")
func unequip_remote(slot_number:int):
	var peer_id:int = multiplayer.get_unique_id()
	var player:Player = Players.get_player_character(peer_id)
	player.unequip("slot_%s"%slot_number)
	
## places an object onto the ground
func place(command: ArgParser):
	if is_help_request(command):
		help(command)
		return

func kick(command:ArgParser):
	if is_help_request(command):
		help(command)
		return
	var user:String = ""
	var m:Array = command.get_argument("--m", "You were kicked from the server.".split(" "))
	var _message:String = ""
	command.print_arguments()
	for word in m:
		_message += "%s "%word

	if command.get_argument("1") != null:
		user = command.get_argument("1")
		NetworkManager.drop_user(user, _message)

## puts user into placement mode with a certain object
func placement(command: ArgParser):
	if is_help_request(command):
		help(command)
		return
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

func print_peer_id(command:ArgParser = null):
	if is_help_request(command):
		help(command)
		return
	UIConsole.instance.print_to_console(str(multiplayer.get_unique_id()))

func print_object_meta(command:ArgParser):
	if is_help_request(command):
		help(command)
		return
	var object_category = 0
	var object_id = 0
	
	if command.get_argument("1") == null:
		help(command)
		return
	if command.get_argument("2") == null:
		help(command)
		return
		
	object_category = command.get_argument("1")
	object_id = int(command.get_argument("2"))
	
	var ob:Node = ObjectIndex.get_object(object_category, object_id)
	if ob == null:
		print_to_console("Object not found. Either the mod_type or ID was incorrect.")
		help(command)
		return
	for meta in ob.get_meta_list():
		var val = ob.get_meta(meta, null)
		print_to_console("[color=green]%s[/color]: [color=yellow]%s[/color]"%[meta, str(val)])
		
func print_object(command:ArgParser):
	if is_help_request(command):
		help(command)
		return
	var print_string:String = ""

	var arg:Array = command.get_argument("--o")	
	if arg == null || arg.size() == 0:
		help(command)
	
	var to_console:Array = []
	
	match arg[0]:
		"players":
			print_string = JSON.stringify(Players.players)	
			to_console.append(print_string)
		"loaded_mods":
			print_string = JSON.stringify(ObjectIndex.index)	
			to_console.append(print_string)
		"index":
			for category in ObjectIndex.index:
				for mod_id in ObjectIndex.index[category]:
					var id:int = mod_id
					var ob = ObjectIndex.index[category][id]
					#var mod_type:String = ob.get_meta("mod_type", "-")
					var item:String = ob.get_meta("name", "[no name]")
					print_string = "%s: %s [%s]"%[category, str(id), item]
					to_console.append(print_string)
					
	for line in to_console:		
		print_to_console(line)

func print_warning_to_console(print_string:String)->void:
	print_to_console("[color=yellow]%s[/color]"%print_string)

func print_error_to_console(print_string:String)->void:
	print_to_console("[color=red]%s[/color]"%print_string)

func print_to_console(print_string:String)->void:
	UIConsole.instance.print_to_console(print_string)

func upload_mod(command:ArgParser):
	if is_help_request(command):
		help(command)
		return
	var mod_path:String = command.get_argument("1")
	Workshop.upload_mod(mod_path)

func update_mod(command:ArgParser):
	if is_help_request(command):
		help(command)
		return

func ip(command:ArgParser):
	if is_help_request(command):
		help(command)
		return
	var ip_addr = NetworkManager.get_machines_ip_address()
	print_to_console(ip_addr)

func shutdown(command:ArgParser):
	if is_help_request(command):
		help(command)
		return
	get_tree().quit()

func server_info(command:ArgParser):
	if is_help_request(command):
		help(command)
		return
	var _ip:String = "[color=green]IP Address:[/color] %s"%NetworkManager.get_machines_ip_address()
	var port:String = "[color=green]Port:[/color] %s"%NetworkManager.current_port
	print_to_console(_ip)
	print_to_console(port)
	
func rick(command:ArgParser):
	if is_help_request(command):
		help(command)
		return
	OS.shell_open("https://www.youtube.com/watch?v=dQw4w9WgXcQ")

#region MINI OS

func ls(command:ArgParser):
	if is_help_request(command):
		help(command)
		return
	MiniOs.ls(command)

func pwd(command:ArgParser):
	if is_help_request(command):
		help(command)
		return
	MiniOs.pwd(command)

func cd(command:ArgParser):
	if is_help_request(command):
		help(command)
		return
	MiniOs.cd(command)

#endregion

## Adds to the CMD history. Should only be used in the CMD command and nowhere else.
func add_cmd_history(command:String):
	history.append(command)
	history_current_index = 0

## Gets CMD history back one index.
func get_cmd_history_back()->String:
	if history.size() == 0:
		return ""
	history_current_index = history_current_index -1
	if history_current_index < 0:
		history_current_index = history.size()-1
	return history[history_current_index]
	
## Gets CMD history forward one index.
func get_cmd_history_forward()->String:
	if history.size() == 0:
		return ""
	if history_current_index == history.size() - 1:
		history_current_index = 0
		return history[0]
	history_current_index = history_current_index +1
	return history[history_current_index]

## For detecting commands that are not typical for chat. Only works if 
## console is open.
func detect_cmd(command_string:String)->String:
	var reserved_commands:Array = [
		"ls", "cd", "pwd", "whoami", "clear", "rick", "ip", "shutdown", "whois",
		
	]
	if UIConsole.instance != null && not UIConsole.instance.is_console_open():
		return command_string
	if command_string.begins_with("/"):
		return command_string
	var command:String = command_string.strip_edges()
	var parts:PackedStringArray = command.split(" ")
	var sample:String = ""
	if parts.size() > 1:
		sample = parts[0].strip_edges()
	else:
		sample = command
	var is_command:bool = false
	
	if reserved_commands.has(sample):
		is_command = true
		
	if is_command:
		command = "/%s"%command_string
	return command

func color_line(line:String, color:Color)->String:	
	return "[color=%s]%s[/color]"%[color.to_html(), line]
