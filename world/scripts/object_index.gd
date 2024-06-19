@icon("res://images/icons/stack.svg")
extends Node

class_name ObjectIndex 

static var object_index = null

## main mod index of game. {ID: Object} format.
## mirrors children of ObjectIndex node like this: 9_$Node
static var index: Dictionary = {}

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
	var id_check =  mod_object.get_meta("id")
	
	var id: int = 0
	if id_check != null:
		id = int(id_check)
	
	var signature: String = AssetLoader.asset_loader.get_mod_name_signature(mod_path, "|")
	
	mod_object.name = signature
	if not index.has(mod_type):
		index[mod_type] = {}
	index[mod_type][id]=mod_object

## important function that "spawns" an item by duplicating it.
## .duplicate() function
## https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-method-duplicate
static func spawn(category: String, id: int):
	var ob: Node = get_object(category, id)
	if ob == null:
		return null
	var spawned = ob.duplicate()
	return spawned

static func get_object(category: String, id: int):
	if not index.has(category):
		return null
	if not index[category].has(id):		
		return null
	return index[category][id]

static func reset():
	object_index.index = {}

static func query(params:Dictionary) -> Dictionary:	
	if not index.has(params["query"]):
		return{}
	var results:Dictionary = index[params["query"]]
	return results
