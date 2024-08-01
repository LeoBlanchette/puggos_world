extends Control

class_name transform_adjuster

@export var ui_vector_3_position: UIVector3
@export var ui_vector_3_rotation: UIVector3
@export var ui_vector_3_scale: UIVector3 

func _ready() -> void:
	Editor.instance.object_transform_changed.connect(set_active_object_new_ui_values)
	Editor.instance.object_selected.connect(set_active_object_new_ui_values)
	ui_vector_3_position.changed.connect(set_active_object_new_position)
	ui_vector_3_rotation.changed.connect(set_active_object_new_rotation)
	ui_vector_3_scale.changed.connect(set_active_object_new_scale)

func set_active_object_new_position():
	if not valid_operation():
		return
	Editor.instance.object_translated_ui.emit(Vector3.ZERO, ui_vector_3_position.value)
	
func set_active_object_new_rotation():
	if not valid_operation():
		return
		
	Editor.instance.object_rotated_ui.emit(Vector3.ZERO, ui_vector_3_rotation.value)
	
func set_active_object_new_scale():
	if not valid_operation():
		return
		
	Editor.instance.object_scaled_ui.emit(Vector3.ZERO, ui_vector_3_scale.value)
	
func valid_operation()->bool:
	if Editor.instance == null:
		return false 
	var active_object = Editor.instance.get_active_object()	
	if active_object == null:
		return false 
	return true

func set_active_object_new_ui_values():
	if Editor.instance == null:
		return
	if Editor.instance.get_active_object() == null:
		return
	
	var active_object:Node3D = Editor.instance.get_active_object()
	
	ui_vector_3_position.value = active_object.global_position
	ui_vector_3_rotation.value = active_object.global_rotation_degrees
	ui_vector_3_scale.value = active_object.scale
