extends Node

class_name PrefabEditor

var prefab_editor_related_mod_groups: Array[String] = [
	"structures/modular/",
	"materials/structures_modular/",
	"items/junk/"
]

@export var prefab_root:Node3D

static var instance = null

# Called when the node enters the scene tree for the first time.
func _ready():	
	if PrefabEditor.instance == null:
		PrefabEditor.instance = self
	else:
		PrefabEditor.instance.queue_free()
		
	load_prefab_editor_related_mods()
	Achievements.achievement.emit("prefab_editor")

func _exit_tree() -> void:
	if PrefabEditor.instance == self:
		PrefabEditor.instance.queue_free()

func load_prefab_editor_related_mods():
	ModManager.mod_manager.load_mods_by_path(prefab_editor_related_mod_groups)

func get_prefab_root()->Node3D:
	return prefab_root

func _on_back_to_world_editor_button_pressed():
	GameManager.change_scene(GameManager.SCENES.WORLD_EDITOR)

func spawn_object(category:String, id:int, pos:Vector3, rot:Vector3):
	var ob:Node3D = ObjectIndex.object_index.spawn(category, id)
	ob.position = pos
	ob.rotation_degrees = rot
	ob.name = ob.get_meta("name", "spawned_object")
	prefab_root.add_child(ob, true)
