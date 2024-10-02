extends Node

var help:String = "Plays an emote by id or name."

func emote(command:ArgParser):
	var peer_id:int = Global.peer_id

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
		id = ObjectIndex.object_index.get_emote_id_by_tag(emote_name_or_id)
		if id == 0:
			Cmd.print_error_to_console("Emote tag '%s' not found."%emote_name_or_id)
			return
	player.emote = id
	
	Cmd.print_to_console("")
	
