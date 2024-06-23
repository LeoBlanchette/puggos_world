extends Node3D

@export var multiplayer_spawner: MultiplayerSpawner
const PLAYER:Resource = preload("res://nodes/characters/player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.is_server():
		player_entered_world()

func _exit_tree() -> void:
	NetworkManager.unregister_world()

func player_entered_world():
	NetworkManager.register_world($".")
	NetworkManager.player_entered_world.rpc_id(1)

## The player spawner of any given world.
@rpc("authority", "call_local", "reliable")
func spawn_player(peer_id:int)->void:
	
	var p = PLAYER.instantiate()
	p.name = str(peer_id)
	p.set_multiplayer_authority(peer_id)
	
	add_child(p)
	
	if p.is_multiplayer_authority():
		p.activate(true)
		print("AUTHORITY %s"%p.name)
	else:
		p.activate(false)
		print("NOT AUTHORITY %s"%p.name)
