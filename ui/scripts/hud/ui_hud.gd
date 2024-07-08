extends Control

@export var player: Player 

static var instance = null

func _ready() -> void:
	if not is_multiplayer_authority():
		hide()
		return
	if instance == null:
		instance = self
	else:
		queue_free()
	

func _exit_tree() -> void:
	if not is_multiplayer_authority():
		return
	if instance == self:
		instance = null

func get_player()->Player:
	return player

func get_player_camera()->Camera3D:
	return player.get_camera()
