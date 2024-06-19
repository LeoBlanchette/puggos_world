extends Control

class_name UIWorld

static var instance:UIWorld = null

const SCENE_TYPE:GameManager.SCENES = GameManager.SCENES.WORLD

func _ready():
	if instance == null:
		instance = self
	else:
		queue_free()

func _exit_tree():
	if instance == self:
		instance = null

static func get_scene_type():
	return UIMain.instance.SCENE_TYPE

static func set_active(active:bool):
	if active:
		instance.show()
	else:
		instance.hide()
