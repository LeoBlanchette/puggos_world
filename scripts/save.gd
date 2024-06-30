extends Node

const DATA_PATH = "user://data/"
const PLAYER_PATH = "user://data/player/"
const SERVER_PATH = "user://data/server/"

func _ready() -> void:
	create_directory_paths()	
	
func save_characters_info(characters:Dictionary)->void:
	var characters_path = FileAccess.open(get_player_path()+"characters.json", FileAccess.WRITE)
	var json_string = JSON.stringify(characters)	
	characters_path.store_line(json_string)

func load_character_info()->Dictionary:
	return get_saved_json(get_character_data_path())
	

func create_directory_paths():
	var save_path:DirAccess = DirAccess.open("user://")
	save_path.make_dir(get_data_path())
	save_path.make_dir(get_player_path())
	save_path.make_dir(get_server_path())

#region paths

func get_data_path()->String:
	return DATA_PATH

func get_player_path()->String:
	return PLAYER_PATH

func get_character_data_path():
	return get_player_path()+"characters.json"

func get_server_path()->String:
	return SERVER_PATH
	
#endregion

func get_saved_json(file_path:String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		return {}
	var saved_data = FileAccess.open(file_path, FileAccess.READ)
	var data:String = saved_data.get_as_text()	
	# Check if there is any error while parsing the JSON string, skip in case of failure
	var parse_result = JSON.parse_string(data)	
	return parse_result

#region save / load levels

func save_prefab_editor():
	pass

func save_world_editor():
	pass
	
func save_world():
	pass

func load_prefab_editor():
	pass

func load_world_editor():
	pass
	
func load_world():
	pass

#endregion 
