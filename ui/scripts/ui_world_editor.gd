extends Control

class_name UIWorldEditor

static var instance:UIWorldEditor = null
const SCENE_TYPE:GameManager.SCENES = GameManager.SCENES.WORLD_EDITOR

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
