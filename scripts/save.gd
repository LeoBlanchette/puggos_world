extends Node

const DATA_PATH = "user://data/"
const PLAYER_PATH = "user://data/player/"
const SERVER_PATH = "user://data/server/"
const PREFABS_PATH = "user://data/prefabs/"
const WORLDS_PATH = "user://data/worlds/"

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
	save_path.make_dir(get_prefabs_path())
	save_path.make_dir(get_worlds_path())

#region paths

func get_data_path()->String:
	return DATA_PATH

func get_player_path()->String:
	return PLAYER_PATH

func get_prefabs_path()->String:
	return PREFABS_PATH
	
func get_worlds_path()->String:
	return WORLDS_PATH

func get_character_data_path():
	return get_player_path()+"characters.json"

func get_prefab_data_path(prefab_name:String):
	return get_prefabs_path()+prefab_name+"/"

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

func get_saved_commands(file_path:String)->Array:
	var commands := []
	var f := FileAccess.open(file_path, FileAccess.READ)
	while not f.eof_reached():
		var line:String = f.get_line()
		commands.append(line)
	return commands

#region save / load levels

func save_prefab_editor(prefab_name:String):
	var prefab_members = get_tree().get_nodes_in_group("prefab_member")
	var saveable_objects := []
	
	for member in prefab_members:
		var saveable_object := SaveableObject.new(member)
		saveable_objects.append(saveable_object)
	
	var saveable_prefab := SaveablePrefab.new(prefab_name, saveable_objects)
	saveable_prefab.save()
	
func save_world_editor():
	pass
	
func save_world():
	pass

func load_prefab_editor(prefab_name:=""):
	var dir = DirAccess.open(get_prefabs_path())
	

	var prefab_data_path:String = get_prefab_data_path(prefab_name)
	var meta_data_path := prefab_data_path+"data.json"
	var commands_path := prefab_data_path+"commands.txt"
	print(meta_data_path)
	print(prefab_data_path)
	if not FileAccess.file_exists(meta_data_path):
		return
	if not FileAccess.file_exists(commands_path):
		return
		
	var meta_data:Dictionary = get_saved_json(meta_data_path)
	var commands:Array = get_saved_commands(commands_path)
	PrefabEditor.instance.load_prefab(meta_data, commands)
	
	
	
func load_world_editor():
	pass
	
func load_world():
	pass

#endregion 

#region save / get mod paths
func save_mod_paths():
	var saveable_text_array:SaveableTextArray = SaveableTextArray.new(Workshop.get_mod_paths())
	saveable_text_array.save(get_data_path()+"mod_paths.txt")

func restore_saved_mod_paths()->void:
	var saveable_text_array:SaveableTextArray = SaveableTextArray.new()
	var mod_paths:Array = saveable_text_array.load_array(get_data_path()+"mod_paths.txt")	 
	Workshop.subscribed_mods_paths = mod_paths 
	
#endregion 
