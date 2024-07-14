extends Control

class_name UIWorldEditor

static var instance:UIWorldEditor = null

const SCENE_TYPE:GameManager.SCENES = GameManager.SCENES.WORLD_EDITOR

var view_port_mode:bool = false

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

func _on_mouse_entered() -> void:
	view_port_mode = true
	if EditorInteractor.instance == null:
		return
	EditorInteractor.instance.entered_viewport.emit(true)

func _on_mouse_exited() -> void:
	view_port_mode = false
	if EditorInteractor.instance == null:
		return
	EditorInteractor.instance.entered_viewport.emit(false)
	
func on_object_selected(ob:Node3D):
	print(ob)


func _on_button_translate_mode_pressed() -> void:
	pass


func _on_button_rotate_mode_pressed() -> void:
	pass # Replace with function body.


func _on_button_scale_mode_pressed() -> void:
	pass # Replace with function body.
