extends Node

var help:String = "Prints the count of players in the game."

func player_count(_command:ArgParser):
	var player_count_label:String = Cmd.color_line("Player count", Color.GREEN)
	var player_count_number:String = Cmd.color_line(str(Players.players.size()), Color.YELLOW)
	Cmd.print_to_console("%s: %s"%[player_count_label, player_count_number])
	
