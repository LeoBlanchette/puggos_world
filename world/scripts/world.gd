extends WorldSystems

class_name World

@export var multiplayer_spawner: MultiplayerSpawner
const PLAYER = preload ("res://nodes/characters/player.tscn")

static var instance = null

var is_world_loaded:bool = false

const MODULAR_OBJECT_INITIATOR: Resource = preload ("res://nodes/build_kits/modular_object_initiator.tscn")

var world_mod_groups: Array[String] = [
	"structures/modular/",
	"materials/structures_modular/",
	"items/junk/",
	"items/general/",
	"items/character/",
	"animations/character/"
]

func _ready() -> void:
	
	if instance == null:
		instance = self
	else:
		queue_free()
	
	load_world_editor_related_mods()
	
	NetworkManager.register_world($".")
	is_world_loaded = true
	NetworkManager.world_loaded.emit()
	ObjectIndex.object_index.spawned.connect(_on_object_spawned)
	
	Achievements.achievement.emit("entered_world")
	

func _enter_tree() -> void:
	multiplayer_spawner.spawn_function = spawn_player

func _exit_tree() -> void:
	NetworkManager.unregister_world()
	if instance == self:
		instance = null

@rpc("authority", "call_local", "reliable")
func do_player_spawn(peer_id: int):
	if not multiplayer.is_server():
		return
	multiplayer_spawner.spawn(peer_id)
	# This is called here because it is certain not to return null 
	# during the request_character_appearance process.
	NetworkManager.request_character_appearance.rpc_id(1, peer_id)

## The player spawner of any given world.
func spawn_player(peer_id: int):
	if not is_world_loaded:
		await NetworkManager.world_loaded
	var p = PLAYER.instantiate()
	p.set_multiplayer_authority(peer_id)
	p.name = "player-%s" %str(peer_id)
	p.peer_id = peer_id
	NetworkManager.player_joined_world.emit(peer_id)
	
	return p

@rpc("any_peer", "call_local", "reliable")
func do_player_interaction(ob_path: String) -> void:
	if not multiplayer.is_server():
		return
	var ob: Node3D = get_node(ob_path)
	if ob.is_in_group("items"):
		ob.queue_free()
		return
	if ob.is_in_group("structures"):
		ob.queue_free()
	return
	
func load_world_editor_related_mods():
	ModManager.mod_manager.load_mods_by_path(world_mod_groups)
	
func add_spawnable_scene(scene: String) -> void:
	multiplayer_spawner.add_spawnable_scene(scene)
	
func _on_object_spawned(ob: Node):
	ObjectGrouper.apply_default_groups(ob)
