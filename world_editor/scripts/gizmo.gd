extends Node3D

class_name EditorGizmo

# rotation
@export var rotate_x_handle:MeshInstance3D
@export var rotate_y_handle:MeshInstance3D
@export var rotate_z_handle:MeshInstance3D
#translation
@export var translate_x_handle:MeshInstance3D
@export var translate_y_handle:MeshInstance3D
@export var translate_z_handle:MeshInstance3D
#scaling
@export var scale_x_handle:MeshInstance3D
@export var scale_y_handle:MeshInstance3D
@export var scale_z_handle:MeshInstance3D
#sliding
@export var slide_x_handle:MeshInstance3D
@export var slide_y_handle:MeshInstance3D
@export var slide_z_handle:MeshInstance3D

static var instance = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if instance == null:
		instance = self
	else:
		queue_free()
	await UIWorldEditor.instance != null
	await UIWorldEditor.instance.is_node_ready()	
	UIWorldEditor.instance.changed_transform_mode.connect(_on_transform_mode_changed)
	reset()
	enter_translate_mode()
	
func _exit_tree() -> void:
	if instance == self:
		instance = null

func set_target(ob:Node3D):
	global_position = ob.global_position
	global_rotation = ob.global_rotation
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#region mode change
func _on_transform_mode_changed(old_mode, new_mode):
	reset()
	match new_mode:
		UIWorldEditor.instance.TranformMode.TRANSLATE:
			enter_translate_mode()
		UIWorldEditor.instance.TranformMode.ROTATE:
			enter_rotate_mode()
		UIWorldEditor.instance.TranformMode.SCALE:
			enter_scale_mode()

func reset()->void:
	# rotation
	rotate_x_handle.hide()
	rotate_y_handle.hide()
	rotate_z_handle.hide()
	#translation
	translate_x_handle.hide()
	translate_y_handle.hide()
	translate_z_handle.hide()
	#scaling
	scale_x_handle.hide()
	scale_y_handle.hide()
	scale_z_handle.hide()
	#sliding
	slide_x_handle.hide()
	slide_y_handle.hide()
	slide_z_handle.hide()

func show_sliders():
	slide_x_handle.show()
	slide_y_handle.show()
	slide_z_handle.show()	

func enter_translate_mode():
	translate_x_handle.show()
	translate_y_handle.show()
	translate_z_handle.show()
	show_sliders()
	
func enter_rotate_mode():
	rotate_x_handle.show()
	rotate_y_handle.show()
	rotate_z_handle.show()

func enter_scale_mode():
	scale_x_handle.show()
	scale_y_handle.show()
	scale_z_handle.show()
	show_sliders()
#endregion
