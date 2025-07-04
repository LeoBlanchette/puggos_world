extends Node

# Steam variables
var is_on_steam_deck: bool = false
var is_online: bool = false
var is_owned: bool = false
var steam_initialized:bool = false
var steam_app_id: int = 2414160

# User
var steam_id: int = 0
var steam_username: String = ""

# Character
var currently_selected_character_id:int = 0
var currently_selected_character_name:String = ""
var character_appearance:Dictionary = {} # Initial "default" appearance of character.

# Network
var peer_id=0

func _init() -> void:
	# Set your game's Steam app ID here
	OS.set_environment("SteamAppId", str(steam_app_id))
	OS.set_environment("SteamGameId", str(steam_app_id))


func _process(_delta: float) -> void:
	Steam.run_callbacks()


func initialize_steam() -> void:
	var initialize_response: Dictionary = Steam.steamInitEx()
	
	if initialize_response['status'] > 0:
		print("Failed to initialize Steam. Shutting down. %s" % initialize_response)
	else:
		steam_initialized = true
	
	# Gather additional data
	is_on_steam_deck = Steam.isSteamRunningOnSteamDeck()
	is_online = Steam.loggedOn()
	is_owned = Steam.isSubscribed()
	steam_id = Steam.getSteamID()
	steam_username = Steam.getPersonaName()
	Steam.getPersonaName()
	Steam.requestCurrentStats()

	# Check if account owns the game
	if is_owned == false:
		print("User does not own this game or steam is not running.")

func is_user_subscribed():
	return Steam.isSubscribed()

func is_steam_running():
	return Steam.isSteamRunning()

func check_steam() -> bool:
	if !Steam.isSteamRunning():
		print_debug("Steam is not running")
		return false
	if !Steam.isSubscribed():
		print_debug("Not subscribed / Ownership is not confirmed")
		return false
	return true

func is_playing_from_editor():
	return OS.has_feature("editor")

func set_currently_selected_character_id(character_id:int)->void:
	currently_selected_character_id = character_id
