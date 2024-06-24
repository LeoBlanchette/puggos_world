extends Node3D

class_name World

@export var multiplayer_spawner: MultiplayerSpawner
const PLAYER = preload("res://nodes/characters/player.tscn")

func _ready() -> void:
	
	NetworkManager.register_world($".")
	NetworkManager.world_loaded.emit()

func _enter_tree() -> void:
	multiplayer_spawner.spawn_function = spawn_player

func _exit_tree() -> void:
	NetworkManager.unregister_world()


@rpc("authority", "call_local", "reliable")
func do_player_spawn(peer_id:int):
	if not multiplayer.is_server():
		return
	multiplayer_spawner.spawn(peer_id)

## The player spawner of any given world.
func spawn_player(peer_id:int):	
	var p = PLAYER.instantiate()		
	p.set_multiplayer_authority(peer_id)
	p.name = "player-%s"%str(peer_id)
	p.peer_id = peer_id	
	NetworkManager.player_joined_world.emit(peer_id)
	return p
	 
