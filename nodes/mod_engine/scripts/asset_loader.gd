@icon("res://images/icons/load.svg")
extends Node
class_name AssetLoader

## Main class for initially scanning and populating asset lists.
## mod format:
## </mods/<mod>.pck
## becomes:
## </mods/<creator>/<project>/<mod_type>/<mod_type_category>/<object>/<object>.tscn , .png | etc
## THUS: 
## 1: creator           - the main author of a set of projects.
## 2: project           - the project of a given mod. Can be an individual thing or a set.
## 3: mod_type          - a broad category of related things. Each "mod type" has it's own id set starting from 1. 
## 4: mod_type_category - a more specific drilldown of the top ID category.
## 5: mod_name          - the individual mod object. Such as a wall, an item, etc.
## See the method get_mod_hierarchy()

signal assets_loaded

static var asset_loader: AssetLoader = null

## Mod directory in the folder of .exe. 
## It is only used in initial loading. After that MOD_FOLDER 
## is the resource folder used.
var MOD_DIRECTORY: String = "mods/"

## Mod RESOURCE folder after mod directory was scanned and loaded.
const MOD_FOLDER: String = "res://mods/"

@export var mod_tree: Node = null

@onready var icon_generator: IconGenerator = $IconGenerator

## Individual .pck files at the res://mods/ directory.
static var mod_packs: Array[String] = [] 

## The creator files found at res://mods/<creator>/ level.
static var creators: Array[String] = [] 

## The creator projects found at res://mods/<creator>/<project>/ level.
static var creator_projects: Array[String] = [] 

## The creator mods found at res://mods/<creator>/<project>/<objects>.../ level.
static var mods: Array[String] = []

## All mod paths
static var mod_paths: Array[String] = []

func _ready() -> void:
	if asset_loader == null:
		asset_loader = self
	else:
		queue_free()

func _exit_tree() -> void:
	if asset_loader == self:
		asset_loader = null
		

## Sets up mod content library.
## called from "_on_asset_loader_ready()" in ModManager
func populate_mod_content():
	populate_mod_packs()
	load_mods()
	populate_creator_directories()
	populate_creator_projects()
	populate_user_mods()
	populate_mod_tree()
	generate_icons()
	assets_loaded.emit()

## gets creator info from the info.tscn node in /mods/creator folder.
func get_mod_info(mod_path: String) -> Dictionary:	
	var mod_info_node: String	
	if mod_path.ends_with("/"):
		mod_info_node = mod_path+"info.tscn"
	elif mod_path.ends_with("info.tscn"):
		mod_info_node = mod_path
	var info: Dictionary = {}	
	if(ResourceLoader.exists(mod_info_node)):
		var info_tscn: Resource = ResourceLoader.load(mod_info_node)
		if info_tscn == null:
			return info
		var info_node: Node = info_tscn.instantiate()
		var keys: Array[String]
		keys.assign(info_node.get_meta_list())
		for key in keys:
			info[key] = info_node.get_meta(key)
	return info

func generate_icons():
	for mod_path in mod_paths:
		if not mod_path.ends_with(".tscn"):
			continue
		
		await get_tree().process_frame		
		icon_generator.generate_icon(mod_path)
		
		
func create_mod_tree_node(node_name: String, meta: Dictionary) -> Node:
	var mod_tree_node: Node = Node.new()
	mod_tree_node.name = node_name	
	for meta_key in meta:
		var meta_value = meta[meta_key]
		mod_tree_node.set_meta(meta_key, meta_value)
	return mod_tree_node

## Resets mod content library. 
func repopulate_mod_content():
	clear_mod_lists()
	populate_mod_content()

## Clears mod lists
func clear_mod_lists():
	mod_packs.clear()
	creators.clear()
	creator_projects.clear()
	mods.clear()
	mod_paths.clear()
	clear_mod_tree()	

## Gets all the .pck files at the root level of res://mods/
func populate_mod_packs():
	if Global.is_playing_from_editor():
		MOD_DIRECTORY = MOD_FOLDER
	
	## This is populated with other directories as well, especially steam mods.
	var mod_directories:Array = []
	
	var local_mods:PackedStringArray = DirAccess.get_directories_at(MOD_DIRECTORY)
	for mod_path in local_mods:
		mod_directories.append("%s%s"%[MOD_DIRECTORY, mod_path])

	for mod_path in Workshop.get_mod_paths():
		mod_directories.append(mod_path)

	for mod_dir in mod_directories:
		var modpacks: Array[String] = HelperFunctions.get_directory_contents(mod_dir, HelperFunctions.Scan.FILES_ONLY)
		for mod in modpacks:
			if mod.ends_with(".pck"):
				print("Found a puggo mod!: " + mod)
				mod_packs.append(mod_dir+"/"+mod)

## Loads all mods registered by populate_mod_paths()
func load_mods():
	for mod_path in mod_packs:
		ProjectSettings.load_resource_pack(mod_path)

## This runs after load_mods() and populates a list of user mods.
## The list should be used for multiple purposes, such as allowing user to 
## choose which mods he will load in-game.
func populate_creator_directories():
	var creator_dirs = HelperFunctions.get_directory_contents(MOD_FOLDER, HelperFunctions.Scan.DIRECTORIES_ONLY)
	for creator in creator_dirs:		
		var creator_dir = (MOD_FOLDER+creator).to_lower()+"/"
		if not creator_dir in creator_dirs:
			creators.append(creator_dir) 
			

## Gets individual user projects. </mods/<user>/<project>/
func populate_creator_projects():	
	for creator in creators:		
		var creator_folder = creator		
		var projects: Array[String] = HelperFunctions.get_directory_contents(creator_folder, HelperFunctions.Scan.DIRECTORIES_ONLY)
		for project in projects:
			var creator_project = (creator_folder+project+"/").to_lower()
			if not creator_project in creator_projects:
				creator_projects.append(creator_project.to_lower())

## Populate user mods
func populate_user_mods():	
	for creator_project in creator_projects:
		for valid_creator_mod_type in ModManager.valid_creator_mod_types:	
		
			var modpath = creator_project+valid_creator_mod_type[0]		
			#var filename = modpath + valid_creator_mod_type[1]		
			var valid_mod_directories = HelperFunctions.get_directory_contents(modpath, HelperFunctions.Scan.DIRECTORIES_ONLY)
			for mod_directory in valid_mod_directories:
				var mod_object = modpath + mod_directory + "/" + valid_creator_mod_type[1]
				if(ResourceLoader.exists(mod_object)):
					mods.append(mod_object)				
				else:
					print("Valid path '"+mod_object+"' not found. See documentation for proper mod folder / filename convention.")


func get_mod_name_signature(mod_path: String, delimiter: String) -> String:
	var mod_hierarchy = get_mod_hierarchy(mod_path)
	
	var mod_signature: String = \
	mod_hierarchy["creator"]+delimiter+\
	mod_hierarchy["project"]+delimiter+\
	mod_hierarchy["mod_type"]+delimiter+\
	mod_hierarchy["mod_type_category"]+delimiter+\
	mod_hierarchy["mod_name"]
	
	return mod_signature

func get_mod_hierarchy(mod_path) -> Dictionary:
	var path_parts = mod_path.split("/")
	var mod_hierarchy: Dictionary = {}
	# extract mod mod_hierarchy 
	mod_hierarchy["creator"] = path_parts[3]
	mod_hierarchy["project"] = path_parts[4]
	mod_hierarchy["mod_type"] = path_parts[5]
	mod_hierarchy["mod_type_category"] = path_parts[6]
	mod_hierarchy["mod_name"] = path_parts[7]
	
	mod_hierarchy["mod_path"] = mod_path
	
	#creates specific mod signature for tree
		
	return mod_hierarchy

func get_mod_creator(mod_path:String)->String:
	return get_mod_hierarchy(mod_path)["creator"]
	
func get_mod_project(mod_path:String)->String:
	return get_mod_hierarchy(mod_path)["project"]	
	
func get_mod_type(mod_path:String)->String:
	return get_mod_hierarchy(mod_path)["mod_type"]	

func get_mod_type_category(mod_path:String)->String:
	return get_mod_hierarchy(mod_path)["mod_type_category"]	
	
func get_mod_name(mod_path:String)->String:
	return get_mod_hierarchy(mod_path)["mod_name"]	
	
	

## Sets up the mod tree itself which contains more info for UI.
func populate_mod_tree():		
	for mod in mods:		
		mod_paths.append(mod)
		
		var mod_hierarchy = get_mod_hierarchy(mod)
		# extract mod mod_hierarchy 
		var creator: String = mod_hierarchy["creator"]
		var project: String = mod_hierarchy["project"]
		var mod_type: String = mod_hierarchy["mod_type"]
		var mod_type_category: String = mod_hierarchy["mod_type_category"]
		var mod_name: String = mod_hierarchy["mod_name"]
		
		# creator node
		if not mod_tree.has_node(creator):
			var creator_meta: Dictionary = get_mod_info(MOD_FOLDER+creator+"/")
			var creator_node: Node = create_mod_tree_node(creator, creator_meta)
			mod_tree.add_child(creator_node)
		
		# creator / project node
		if not mod_tree.has_node(creator+"/"+project):
			var mod_meta: Dictionary = get_mod_info(MOD_FOLDER+creator+"/"+project+"/")			
			var project_node: Node = create_mod_tree_node(project, mod_meta)
			mod_tree.find_child(creator, false, false).add_child(project_node)
		
		# creator / project / category_1 node
		if not mod_tree.has_node(creator+"/"+project+"/"+mod_type):
			var mod_type_node: Node = create_mod_tree_node(mod_type, {})
			mod_tree.find_child(creator, false, false)\
			.find_child(project, false, false)\
			.add_child(mod_type_node)
			

		# creator / project / category_1 / category_2 node
		if not mod_tree.has_node(creator+"/"+project+"/"+mod_type+"/"+mod_type_category):
			var mod_type_category_node: Node = create_mod_tree_node(mod_type_category, {})
			mod_tree.find_child(creator, false, false)\
			.find_child(project, false, false)\
			.find_child(mod_type, false, false)\
			.add_child(mod_type_category_node)
			
			
		# endpoint node (the mod)
		var mod_info: Dictionary = get_mod_info(mod)
		if not mod_tree.has_node(creator+"/"+project+"/"+mod_type+"/"+mod_type_category+"/"+mod_name):
			mod_info["mod_path"] = mod
			var mod_name_node: Node = create_mod_tree_node(mod_name, mod_info)
			mod_tree.find_child(creator, false, false)\
			.find_child(project, false, false)\
			.find_child(mod_type, false, false)\
			.find_child(mod_type_category, false, false)\
			.add_child(mod_name_node)

## Clears the mod node tree
func clear_mod_tree():
	for child in mod_tree.get_children():
		child.queue_free()
		
static func get_mods_list() -> Array[String]:	
	return mod_paths
	
static func get_mod_folder():
	return MOD_FOLDER
