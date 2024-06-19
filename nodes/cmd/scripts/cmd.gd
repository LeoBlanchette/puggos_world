@icon("res://images/icons/computer.svg")
extends Node


## beginning root of the cmd cycle
func cmd(command_string:String):	
	
	if command_string.begins_with("/message"):
		message(command_string)
		return	
	if not command_string.begins_with("/"):
		chat(command_string)
		return
	
	command_string = command_string.to_lower()
	
	var command:PackedStringArray= parse(command_string)
	
	if command.size() == 0:
		return
	
	match command[0]:
		"/give":
			give(command)
		"/equip":
			equip(command)
		"/placement":
			placement(command)
		"/place":
			place(command)
		"/print_command":
			print_command(command)
		"/print_players_object":
			print_players_object()
		"/print_peer_id":
			print_peer_id()


## general chat messages
func chat(command:String):
	if not multiplayer.is_server():
		NetworkManager.send_server_chat_message.rpc_id(1, command)
	else:
		NetworkManager.server_chat_message.rpc(command)
		
## specific chat messages
func message(command:String):
	pass	

## gives player a thing
func give(command: PackedStringArray):
	pass

## equips a thing to the player
func equip(command: PackedStringArray):
	pass

## places an object onto the ground
func place(command: PackedStringArray):
	pass

func print_command(command:PackedStringArray):
	var args: ArgParser = ArgParser.new(command)
	args.print_arguments()

func print_peer_id():
	UIConsole.instance.print_to_console(str(multiplayer.get_unique_id()))

func print_players_object():
	var json_string = JSON.stringify(Players.players)	
	print(json_string)
	UIConsole.instance.print_to_console(json_string)
	
## puts user into placement mode with a certain object
func placement(command: PackedStringArray):
	var reject_message:String = "Something went wrong."
	var peer_id:int = multiplayer.get_unique_id()	
	var object_category = 0
	var object_id = 0
	if command.size() == 3: #the target user is ommitted...assume user is sender.
		object_category = command[1]
		object_id = int(command[2])
	if command.size() == 4: #the target user is other than sender.
		object_category = command[2]
		object_id = int(command[3])
		if peer_id == 0:
			chat(reject_message)
			return 
		pass
	
	var player = Players.get_player_character(peer_id)
	if player == null:
		chat(reject_message)
		return	
	print(player)
	player.enter_placement_mode(object_category, object_id)


func parse(command:String) -> PackedStringArray:
	var command_parsed = command.split(" ", false)
	
	var command_dict:Dictionary = {}
	
	command_dict["args"] = command_parsed

	return command_parsed
