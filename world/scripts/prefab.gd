extends Node3D

class_name Prefab

func build(meta_data:Dictionary, commands:Array)->void:
	mark_prefab_root(self)
	if meta_data.has("name"):
		name = meta_data["name"]
	for command_string:String in commands:
		if command_string.is_empty():
			continue
		var command:ArgParser = ArgParser.new(command_string)
		if command.arguments.is_empty():
			continue
		var object_category = 0
		var object_id = 0

		object_category = command.get_argument("1")
		
		object_id = int(command.get_argument("2"))
		var pos = command.vector_from_array(command.get_argument("--p", Vector3.ZERO))
		var rot = command.vector_from_array(command.get_argument("--r", Vector3.ZERO))
		anchor_object(object_category, object_id, pos, rot)

func unpack():
	remove_meta("prefab_root")
	for child:Node in HelperFunctions.get_all_children(self):
		child.remove_meta("prefab_root")
	var new_parent:Node3D = get_parent_node_3d()
	for child in get_children():
		child.reparent(new_parent)
		if Editor.instance != null:
			Editor.instance.assign_object_root(child)
	queue_free()

func anchor_object(category:String, id:int, pos:Vector3, rot:Vector3)->void:
	var ob:Node3D = ObjectIndex.object_index.spawn(category, id)
	ob.position = pos
	ob.rotation_degrees = rot
	mark_prefab_root(ob)
	for child:Node in HelperFunctions.get_all_children(ob):
		mark_prefab_root(child)
	
	ob.name = ob.get_meta("name", "spawned_object")
	self.add_child(ob, true)

func mark_prefab_root(ob:Node)->void:
	if not ob.has_meta("prefab_root"):
		ob.set_meta("prefab_root", self.get_instance_id())

func set_to_gizmo():
	if EditorGizmo.instance != null:
		global_position = EditorGizmo.instance.global_position
		global_rotation = EditorGizmo.instance.global_rotation
		
static func get_prefab_root(ob:Node)->Prefab:
	var id:int = ob.get_meta("prefab_root", 0)
	if id == 0:
		return null
	var root = instance_from_id(id)
	if root != null:
		return root
	return null

static func is_prefab(ob:Node)->bool:
	if ob == null:
		return false
	var id:int = ob.get_meta("prefab_root", 0)
	if id > 0:
		return true
	return false
