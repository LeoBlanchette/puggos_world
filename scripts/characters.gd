extends Node

var characters: Dictionary = {
	"characters": [],
	"current_character": 0
}

func _ready() -> void:
	load_characters()

func load_characters():
	self.characters = Save.load_character_info()
	if characters.is_empty():
		reset_characters()
	Global.currently_selected_character_id = characters["current_character"]
	

func get_characters_template()->Dictionary:
	var characters_template: Dictionary = {
		"characters": [],
		"current_character": 0
	}		
	return characters_template

func reset_characters():
		characters = get_characters_template()
		characters["characters"].append(get_default_character())
		characters["current_character"] = 0
		Save.save_characters_info(self.characters)
		
func get_default_character() ->Dictionary:
	var _new_character:Dictionary = new_character()
	_new_character["id"] = 0
	return _new_character
	
func get_currently_selected_character_name()->String:
	var character_id: int = get_currently_selected_character_id()
	var character:Dictionary = get_character_by_id(character_id)
	
	return character["name"]
	
func get_currently_selected_character_id()->int:
	return self.characters["current_character"]

func set_currently_selected_character_id(character_id:int)->void:
	self.characters["current_character"] = character_id
	Global.currently_selected_character_id = character_id
	save_characters()

func new_character(_name:String = "")->Dictionary:
	var character:Dictionary = {
		"id" = 0,
		"name" = "",		
	}
	if name.is_empty():
		character["name"] = Global.steam_username
	else: 
		character["name"] = _name
		
	var rng = RandomNumberGenerator.new()
	character["id"] = rng.randf_range(0, 2147483647)
	return character

func get_character(idx:int)->Dictionary:	
	return get_characters()[idx]

func get_character_by_id(id:int)->Dictionary:
	for x in range(get_characters().size()):
		if get_characters()[x]["id"] == id:
			return get_character(x)		
	return {}

func get_characters()->Array:
	return self.characters["characters"]

func add_character():
	var character:Dictionary = new_character()
	characters["characters"].append(character)

func delete_character_by_id(character_id:int)->void:
	if character_id == 0:
		return
	for x in range(get_characters().size()):
		if get_characters()[x]["id"] == character_id:
			get_characters().remove_at(x)
	save_characters()

func save_character(character_info:Dictionary)->void:
	var exists = false
	for x in get_characters().size():
		if get_characters()[x]["id"] == character_info["id"]:
			characters["characters"][x] = character_info
			exists = true
	if not exists:
		get_characters().append(character_info)
	save_characters()
	load_characters()

func save_characters():
	print("Saving characters...")
	Save.save_characters_info(self.characters)
