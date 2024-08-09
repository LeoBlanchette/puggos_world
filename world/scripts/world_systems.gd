extends Node

class_name  WorldSystems

static var current_world := ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ObjectIndex.object_index.spawned.connect(_on_object_spawned)

@rpc("any_peer", "call_local", "reliable")
func spawn_object(category:String, id:int, pos:Vector3, rot:Vector3):
	if not multiplayer.is_server():
		return
	var ob:Node3D = ObjectIndex.object_index.spawn(category, id)
	ob.position = pos
	ob.rotation_degrees = rot
	ob.name = ob.get_meta("name", "spawned_object")
	self.add_child(ob, true)

func add_prefab(prefab:Prefab, pos:Vector3, rot:Vector3)->void:
	add_child(prefab)


func _on_object_spawned(ob:Node):
	ObjectGrouper.apply_default_groups(ob)
