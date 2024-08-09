extends Node3D

class_name Prefab

func build(meta_data:Dictionary, commands:Array)->void:
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

func anchor_object(category:String, id:int, pos:Vector3, rot:Vector3)->void:
	var ob:Node3D = ObjectIndex.object_index.spawn(category, id)
	ob.position = pos
	ob.rotation_degrees = rot
	ob.name = ob.get_meta("name", "spawned_object")
	self.add_child(ob, true)
