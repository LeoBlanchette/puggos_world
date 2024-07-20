extends WorldSystems

class_name WorldEditor

static var instance:WorldEditor = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if instance == null:
		instance = self
	else:
		queue_free()
	
	Achievements.achievement.emit("world_editor")

func _exit_tree() -> void:
	if instance == self:
		instance = null
