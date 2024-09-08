@icon("res://images/icons/stack.svg")
extends Node

## This is the main object index. It gets it's information from the 
## asset loader.

class_name ObjectIndex 

signal spawned(ob:Node)

static var object_index:ObjectIndex = null

## main mod index of game. {ID: Object} format.
## mirrors children of ObjectIndex node like this: 9_$Node
static var index: Dictionary = {}

const DYNAMIC_ICON = preload("res://nodes/dynamic_icon/dynamic_icon.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if ObjectIndex.object_index == null:
		ObjectIndex.object_index = self
	else:
		queue_free()

func _exit_tree() -> void:
	if ObjectIndex.object_index == self:
		ObjectIndex.object_index = null

static func add_object_to_index(mod_object: Node):
	var mod_path = mod_object.get_meta("mod_path")
	var mod_type = mod_object.get_meta("mod_type")
	#var mod_type_category = mod_object.get_meta("mod_type_category")
	var id_check =  mod_object.get_meta("id", 0)
	
	if id_check == 0:
		print("No ID associated with %s. Cannot add it to index."%mod_path)
		return
	
	var id: int = 0
	if id_check != null:
		id = int(id_check)
	
	var signature: String = AssetLoader.asset_loader.get_mod_name_signature(mod_path, "|")
	mod_object.name = signature
	
	if not index.has(mod_type):
		index[mod_type] = {}
	index[mod_type][id]=mod_object

static func spawn(category: String, id: int):
	var ob: Node = get_object(category, id)
	if ob == null:
		return
	var mod_path:String = ob.get_meta("mod_path", "")
	if mod_path.is_empty():
		print("mod_path meta not found on %s"%ob)
		return		
	var spawned = ResourceLoader.load(mod_path).instantiate()
	ObjectIndex.object_index.spawned.emit(spawned)
	return spawned

static func has_object(category: String, id: int)->bool:
	if not index.has(category):
		return false
	if not index[category].has(id):		
		return false
	return true

static func get_object(category: String, id: int):
	if not index.has(category):
		return null
	if not index[category].has(id):		
		return null
	return index[category][id]

static func reset():
	object_index.index = {}

func get_all_mod_objects()->Array:
	var mod_objects:Array = []
	for key in ObjectIndex.index:
		for id in index[key]:
			mod_objects.append(index[key][id])
	return mod_objects
			

func get_mod_dir(object_category:String, id:int)->String:
	var ob:Node = ObjectIndex.get_object(object_category, id)
	if ob == null:
		return ""
	var path:String = ob.scene_file_path
	var dir:String = path.get_base_dir()
	
	return dir

func get_animation_name(id:int, default:String="")->String:
	var animation:Animation = get_animation(id)
	if animation == null:
		return default
	return animation.resource_name

## Gets an animation path based on it's ID.
func get_animation_path(id:int)->String:
	var dir:String = get_mod_dir("animations", id)
	var ob:Node = ObjectIndex.get_object("animations", id)
	if ob == null:
		return ""
	var animation_name:String = ob.get_meta("mod_name")
	var animation_path = "%s/%s%s"%[dir,animation_name, ".res"]
	if not FileAccess.file_exists(animation_path):
		print("Animation not found at %s"%animation_path)
		return ""
	return animation_path

## Gets animation based on it's ID.
func get_animation(id)->Animation:
	var animation_path:String = get_animation_path(id)
	if animation_path.is_empty():
		return null
	var animation = load(animation_path)
	if animation == null:
		print("Animation == null. Resource loaded from: %s"%animation_path)
		return null
	return animation

func get_all_animation_paths()->Array:
	var animation_paths:Array = []
	if not index.has("animations"):
		return []
	for key in index["animations"]:
		var path:String = get_animation_path(key)
		animation_paths.append(path)
	return animation_paths


static func query(params:Dictionary) -> Dictionary:	
	if not index.has(params["query"]):
		return{}
	var results:Dictionary = index[params["query"]]
	return results

func get_icon(mod_type:String, id:int, size_x:int = 512, size_y:int = 512)->DynamicIcon:
	var ob:Node3D = get_object(mod_type, id)
	var tmp_ob:Node3D = ob.duplicate()
	
	var dynamic_icon:DynamicIcon = DYNAMIC_ICON.instantiate()	
	add_child(dynamic_icon)
	dynamic_icon.set_icon_size(size_x, size_y)
	dynamic_icon.name = "dynamic_icon:%s"%[tmp_ob.get_meta("mod_name", tmp_ob.name)]
	dynamic_icon.subject = tmp_ob
	dynamic_icon.capture()	
	await  dynamic_icon.icon_ready
	return dynamic_icon
