extends Node3D

@export var multiplayer_spawner: MultiplayerSpawner
const PLAYER = preload("res://nodes/characters/player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.is_server():
		player_entered_world()

func _enter_tree() -> void:
	multiplayer_spawner.spawn_function = spawn_player

func _exit_tree() -> void:
	NetworkManager.unregister_world()

func player_entered_world():	
	NetworkManager.register_world($".")
	NetworkManager.player_entered_world.rpc_id(1)

@rpc("authority", "call_local", "reliable")
func do_player_spawn(peer_id:int):
	multiplayer_spawner.spawn(peer_id)

## The player spawner of any given world.

func spawn_player(peer_id:int):	
	var p:Player = PLAYER.instantiate()	
	
	p.name = "player-%s"%str(peer_id)
	p.set_multiplayer_authority(peer_id)
	p.peer_id = peer_id
	p.multiplayer_synchronizer.set_multiplayer_authority(peer_id)
	
	return p
	 
