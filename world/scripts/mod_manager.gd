@icon("res://images/icons/blocks.svg")
extends Node

## The central manager for loading and managing mods on game start
## and world loading.

class_name ModManager

#region post-processing of mods
## After mods are loaded and initial meta data is added, 
## all mods are run through an analysis for post processing
## for example, "mark_animation_types()" in this class 
## utilizes it to add more meta data to animation tscn objects
signal pre_analyze_mod(mod)
signal post_analyze_mod(mod)
#endregion

static var mod_manager: ModManager = null

## IMPORTANT array that contains the core information for mod scanning
## valid_mod_types
static var valid_creator_mod_types: Array = [
	["terrains/terrain/", "terrain.tscn"],
	["structures/modular/", "structure.tscn"],
	["materials/structures_modular/", "material.tres"],
	["images/player_faces/", "face.png"],
	["items/junk/", "item.tscn"],
	["items/general/", "item.tscn"],
	["items/character/", "item.tscn"],
	["animations/character/", "animation.tscn"],
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	if ModManager.mod_manager == null:
		ModManager.mod_manager = self
		Workshop.mod_paths_updated.connect(populate_mod_content_from_workshop_update)
		pre_analyze_mod.connect(mark_animation_types)
	else:
		queue_free()
	

func _exit_tree() -> void:
	if ModManager.mod_manager == self:
		ModManager.mod_manager = null

func analyze_loaded_mods():
	var mod_objects:Array = ObjectIndex.object_index.get_all_mod_objects()
	for mod_object in mod_objects:
		pre_analyze_mod.emit(mod_object)
		post_analyze_mod.emit(mod_object)

func load_mod_from_path(mod_path: String):
	var loaded_mod = load(mod_path)

	if mod_path.ends_with(".tscn"):
		var instanced_mod = loaded_mod.instantiate()
		instanced_mod.set_meta("mod_path", mod_path)
		return instanced_mod
	return null


## loads mods by path parts supplied, such as "/structures/modular/" 
func load_mods_by_path(asset_paths: Array[String]):
	var mods: Array[String] = filter_mod_list_by_paths(asset_paths)
	for mod in mods:
		#get the mod
		var instanced_mod = load_mod_from_path(mod)
		if instanced_mod == null:
			print_debug("instanced_mod is null mod: "+mod)
			continue		
		#get the mod's signature and path info for use in indexer
		var mod_hierarchy: Dictionary = AssetLoader.asset_loader.get_mod_hierarchy(mod)
		for key in mod_hierarchy:
			instanced_mod.set_meta(key, mod_hierarchy[key])
		ObjectIndex.add_object_to_index(instanced_mod)
		if World.instance != null:
			World.instance.add_spawnable_scene(mod)	
	analyze_loaded_mods()

'''
## unloads mods by path parts supplied, such as "/structures/modular/" 	
func unload_mods_by_paths(asset_paths: Array[String]):
	
	var mods: Array[String] = filter_mod_list_by_paths(asset_paths)
	mods = ["IN PROGRESS"]
	pass
'''

## provide paths such as "/structures/modular/" and it will return all mods 
## containing the string matching the path string parts supplied
func filter_mod_list_by_paths(asset_paths) -> Array[String]:
	var matches: Array[String] = []
	var mod_list: Array[String] = AssetLoader.get_mods_list()
	
	for mod in mod_list:
		for asset_path in asset_paths:
			if asset_path in mod:
				matches.append(mod)
	
	return matches

'''
func clear_mods(asset_paths: Array[String]):
	pass
'''
	
## Triggered at Workshop.mod_paths_updated.emit()
## This happens when the workshop updates from steam.
## This will fire twice if after initial loading, more subscriptions
## are found.
func populate_mod_content_from_workshop_update():
	AssetLoader.asset_loader.populate_mod_content()
	
func mark_animation_types(mod:Node):
	var mod_type:String = mod.get_meta("mod_type", "")
	var mod_name:String = mod.get_meta("mod_name", "")

	# Mark if it is a personality, for in-game detection.
	if mod_name.begins_with("personality_") && mod_type == "animations":
		mod.set_meta("personality", true)
