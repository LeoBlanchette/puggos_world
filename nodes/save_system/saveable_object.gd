extends Node

class_name SaveableObject

#region identification
var id:int = 0
var mod_creator:String
var mod_project:String 
var mod_type:String
var mod_type_category:String
var mod_name:String 
#endregion

#region transform
var global_postion:Vector3
var global_rotation:Vector3
var global_scale:Vector3
#endregion

func _init(ob:Node3D) -> void:
	if not is_valid(ob):
		return
	record_common_data(ob)
	populate_mod_hierarchy(ob)
	record_transform(ob)

func record_common_data(ob:Node3D)->void:
	id = ob.get_meta("id", 0)

func record_transform(ob:Node3D):
	global_postion = ob.global_position
	global_rotation = ob.global_rotation_degrees
	global_scale = ob.scale

func populate_mod_hierarchy(ob:Node):
	var mod_path:String = ob.scene_file_path
	if mod_path.is_empty():
		return
	var mod_hierarchy:Dictionary = AssetLoader.asset_loader.get_mod_hierarchy(mod_path)
	mod_creator = "creator_%s"%mod_hierarchy["creator"]
	mod_project = "project_%s"%mod_hierarchy["project"]
	mod_type = mod_hierarchy["mod_type"]
	mod_type_category = mod_hierarchy["mod_type_category"]
	mod_name = mod_hierarchy["mod_name"]
	
func is_valid(ob:Node3D)->bool:	
	if not ob.has_meta("id"):
		return false	
	return true

func get_restoration_command()->String:
	var pos:String = ArgParser.string_argument_from_vector("--p", global_postion)
	var rot:String = ArgParser.string_argument_from_vector("--r", global_rotation)
	
	var format_dict:Dictionary = {
		"mod_type":mod_type,
		"id":id,
		"pos":pos,
		"rot":rot,
	}
	return "/spawn {mod_type} {id} {pos} {rot}".format(format_dict)
	
