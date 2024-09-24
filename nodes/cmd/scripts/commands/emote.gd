extends Node

var help:String = "Plays an emote by id or name."

func emote(command:ArgParser):
	var peer_id:int = Global.peer_id
	print(peer_id)
	var player:Player = Players.get_player_character(peer_id)
	if player == null:
		Cmd.print_to_console("Something went wrong.")
		return
		
	var emote_name_or_id:String = command.get_second_argument()
	if emote_name_or_id.is_empty():
		Cmd.print_to_console("Please supply Emote ID or Key (name)")
		return
	
	var id:int = emote_name_or_id.to_int()
	
	if id == 0: # This means that a string was supplied that was a name.
		pass
	else:
		player.emote = id
	
	Cmd.print_to_console("")
	
