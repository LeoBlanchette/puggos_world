extends Node

# Called when the node enters the scene tree for the first time.
func activate() -> void:	
	GameManager.instance.register_player(get_parent())	
	
	queue_free()
