extends Node

## a list of player dictionaries.
## {<steam_id>: 
##    {
##		"<steam_username>": "etc", 
##		"<other_info>": "etc", 
##    {
## } 
var players = {}

func _ready() -> void:
	Steam.avatar_loaded.connect(avatar_loaded)

func add_player(peer_id:int, steam_id:int, persona_name:String, character_name:String = ""):
	var player: Dictionary = {
		"peer_id" = peer_id,
		"steam_id" = steam_id,
		"name" = persona_name,
		"character_name" = character_name,
		"nickname" = Steam.getPlayerNickname(steam_id),
		"character" = null,
		"avatar" = null,
	}
	
	player["character"] = get_character_object_by_peer_id(peer_id)
	
	players[peer_id] = player	
	retrieve_player_avatar(steam_id)

func update_character_objects():
	for peer_id in players:
		players[peer_id]["character"] = get_character_object_by_peer_id(peer_id)

func get_character_object_by_peer_id(peer_id:int)->Player:
	var players = get_tree().get_nodes_in_group("players")
	for player:Player in players:
		var character_peer_id:int = player.get_peer_id()
		if character_peer_id == peer_id:
			return player
	return null


func retrieve_player_avatar(steam_id:int):
	Steam.getPlayerAvatar(Steam.AVATAR_SMALL, steam_id )

func get_player_character_name(peer_id:int)->String:
	var player:Dictionary = get_player(peer_id)
	if player.is_empty():
		return "-"
	return player["character_name"]
	
func get_player_name(peer_id:int)->String:
	var player:Dictionary = get_player(peer_id)
	if player.is_empty():
		return "-"
	return player["name"]
	
func get_player_avatar(steam_id:int) -> ImageTexture:	
	for peer_id in players:
		if players[peer_id]["steam_id"] == steam_id:
			if players[peer_id]["avatar"] == null:
				retrieve_player_avatar(steam_id)
			return players[peer_id]["avatar"]
	return null

func avatar_loaded(steam_id, size, buffer):	
	var avatar_image = Image.create_from_data(size, size, false, Image.Format.FORMAT_RGBA8, buffer)
	var image_texture = ImageTexture.create_from_image(avatar_image)
	for peer_id in players:
		if players[peer_id]["steam_id"] == steam_id:
			players[peer_id]["avatar"]=image_texture
	
func get_player(peer_id:int)->Dictionary:
	if players.has(peer_id):
		return players[peer_id]
	return {}

func get_player_id_by_name(player_name:String) -> int:	
	for peer_id in players:		
		if players[peer_id]["name"].to_lower() == player_name.to_lower():
			return peer_id
	return 0

func get_player_character(peer_id:int) -> Node:
	if not players.has(peer_id):
		return null
	return players[peer_id]["character"]

func set_player_character(peer_id:int, character:Node)->bool:
	if not players.has(peer_id):
		return false
	players[peer_id]["character"] = character
	return true

func get_player_info_by_peer_id(peer_id:int)->Dictionary:
	for key in players:
		if players[key].has("peer_id"):
			if players[key]["peer_id"] == peer_id:
				return players[key]
	return {}

func get_player_peer_id_by_steam_id(steam_id:int)->int:
	for key in players:
		if players[key].has("steam_id"):
			if players[key]["steam_id"] == steam_id:
				return key
	return 0

func get_player_steam_id_by_peer_id(peer_id:int)->int:
	if players.has(peer_id):
		return players[peer_id]["steam_id"]
	return 0

func get_peer_id_by_persona_name(persona_name:String)->int:
	for peer_id in players:
		if players[peer_id]["name"].to_lower() == persona_name.to_lower().strip_edges():
			return peer_id
	return 0

func remove_player_by_peer_id(peer_id:int):
	if players.has(peer_id):
		players.erase(peer_id)
