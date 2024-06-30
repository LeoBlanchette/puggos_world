extends Node

class_name SaveablePrefab

var saveable_objects := []
var prefab_name := ""
var save_path :=""
var meta_data :=""
var command_data :=""

func _init(_prefab_name := "", _saveable_objects := []):
	prefab_name = _prefab_name.strip_edges().to_lower()
	saveable_objects = _saveable_objects
	save_path = get_prefab_path()
	build_meta_data()
	build_command_data()

func get_prefab_path()->String:
	return Save.get_prefab_data_path(prefab_name)

func build_meta_data():
	var meta_data_dict := {
		"prefab_name": prefab_name
	}
	meta_data = JSON.stringify(meta_data_dict)
	
func build_command_data():
	for saveable_object:SaveableObject in saveable_objects:
		command_data+=saveable_object.get_restoration_command()+"\n"
	
func save():
	var user_dir:DirAccess = DirAccess.open(Save.PREFABS_PATH)
	user_dir.make_dir(get_prefab_path())
	
	var meta = FileAccess.open(save_path+"data.json", FileAccess.WRITE)
	meta.store_string(meta_data)
	
	var commands = FileAccess.open(save_path+"commands.txt", FileAccess.WRITE)
	commands.store_string(command_data)
