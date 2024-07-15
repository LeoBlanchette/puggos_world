extends Control

class_name UIWorldEditor

static var instance:UIWorldEditor = null
const SCENE_TYPE:GameManager.SCENES = GameManager.SCENES.WORLD_EDITOR

signal changed_transform_mode(old_mode, new_mode)
enum TranformMode{
	TRANSLATE,
	ROTATE,
	SCALE,
}
var current_transform_mode:TranformMode = TranformMode.TRANSLATE

var view_port_mode:bool = false

@export var transform_button_group:ButtonGroup


func _ready():	
	if instance == null:
		instance = self
	else:
		queue_free()
	var first:bool = true
	for button in transform_button_group.get_buttons():
		button.connect("pressed", _on_transform_button_pressed)


	
func _exit_tree():
	for button in transform_button_group.get_buttons():
		button.disconnect("pressed", _on_transform_button_pressed)
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

func activate_default_transform_button()->void:
	var default_button:Button = transform_button_group.get_buttons()[0]
	default_button.emit_signal("pressed")
	
func _on_transform_button_pressed():
	var pressed_button:Button = transform_button_group.get_pressed_button()
	var previous_transform_mode = current_transform_mode
	match pressed_button.name:
		"ButtonTranslateMode":
			current_transform_mode = TranformMode.TRANSLATE
		"ButtonRotateMode":
			current_transform_mode = TranformMode.ROTATE
		"ButtonScaleMode":
			current_transform_mode = TranformMode.SCALE
			
	changed_transform_mode.emit(previous_transform_mode, current_transform_mode)
