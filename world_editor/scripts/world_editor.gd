extends WorldSystems

class_name WorldEditor

static var instance:WorldEditor = null

@export var terrain_editor:Node3D

var world_editor_related_mod_groups: Array[String] = [
	"terrains/terrain/",
	"structures/modular/",
	"materials/structures_modular/",
	"emotes/character/",
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if instance == null:
		instance = self
	else:
		queue_free()
	super._ready()
	load_world_editor_related_mods()
	terrain_editor.initiate()
	Achievements.achievement.emit("world_editor")

func _exit_tree() -> void:
	if instance == self:
		instance = null

func load_world_editor_related_mods():
	ModManager.mod_manager.load_mods_by_path(world_editor_related_mod_groups)
