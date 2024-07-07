extends Control


static var instance = null

func _ready() -> void:
	if not is_multiplayer_authority():
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
