extends Node

class_name  WorldSystems

static var current_world := ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ObjectIndex.object_index.spawned.connect(_on_object_spawned)

@rpc("any_peer", "call_local", "reliable")
func spawn_object(category:String, id:int, pos:Vector3, rot:Vector3):
	print("HERE")
	if not multiplayer.is_server():
		return
	var ob:Node3D = ObjectIndex.spawn(category, id)
	ob.position = pos
	ob.rotation_degrees = rot
	ob.name = ob.get_meta("name", "spawned_object")
	self.add_child(ob, true)

func add_prefab(prefab:Prefab, _pos:Vector3, _rot:Vector3)->void:
	add_child(prefab)
	prefab.set_to_gizmo() #this will only work if Gizmo instance != null.


func _on_object_spawned(ob:Node):
	ObjectGrouper.apply_default_groups(ob)
