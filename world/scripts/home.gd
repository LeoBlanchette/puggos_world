extends WorldSystems


class_name Home

static var instance = null

const MODULAR_OBJECT_INITIATOR: Resource = preload ("res://nodes/build_kits/modular_object_initiator.tscn")
const PLAYER = preload("res://nodes/characters/player.tscn")

@onready var character_spawn: Marker3D = $CharacterSpawn
@onready var camera_3d: Camera3D = $Camera3D
var player:Player = null

var world_mod_groups: Array[String] = [
	"items/character/",
	"animations/character/"
]

func _ready() -> void:

	if instance == null:
		instance = self
	else:
		queue_free()	
	load_world_editor_related_mods()
	spawn_preview_character()
	#camera_3d.current = true
	GameManager.instance.ui_ready.connect(populate_character_options)

func _exit_tree() -> void:
	# This was commented out because it seems to be a race condition 
	# where it nulls out the new world.
	#NetworkManager.unregister_world()
	if instance == self:
		instance = null
 
func load_world_editor_related_mods():
	ModManager.mod_manager.load_mods_by_path(world_mod_groups)
	
func spawn_preview_character():
	for child in character_spawn.get_children():
		child.queue_free()
	player = PLAYER.instantiate()
	character_spawn.add_child(player)
	player.rotation_degrees = Vector3.ZERO
	player.position = Vector3.ZERO
	player.display_mode = true
	player.is_long_idle = true
	
	
func populate_character_options():
	CharacterOptions.instance.player = player
	CharacterOptions.instance.populate_character_options()
