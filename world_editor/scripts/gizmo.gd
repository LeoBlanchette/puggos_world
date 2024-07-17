extends Node3D

class_name EditorGizmo

const RAY_LENGTH:float = 1000

#region materials
const FLAT_BLUE:StandardMaterial3D = preload("res://materials/ui/flat_blue.tres")
const FLAT_BLUE_HIGHLIGHTED:StandardMaterial3D = preload("res://materials/ui/flat_blue_highlighted.tres")
const FLAT_GREEN:StandardMaterial3D = preload("res://materials/ui/flat_green.tres")
const FLAT_GREEN_HIGHLIGHTED:StandardMaterial3D = preload("res://materials/ui/flat_green_highlighted.tres")
const FLAT_RED:StandardMaterial3D = preload("res://materials/ui/flat_red.tres")
const FLAT_RED_HIGHLIGHTED:StandardMaterial3D = preload("res://materials/ui/flat_red_highlighted.tres")
#endregion materials

#region handle parents
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
var handles:Array[MeshInstance3D] = []
#endregion

#region handle static bodies
# rotation
@export var rotate_x_handle_static_body:StaticBody3D
@export var rotate_y_handle_static_body:StaticBody3D
@export var rotate_z_handle_static_body:StaticBody3D
#translation
@export var translate_x_handle_static_body:StaticBody3D
@export var translate_y_handle_static_body:StaticBody3D
@export var translate_z_handle_static_body:StaticBody3D
#scaling
@export var scale_x_handle_static_body:StaticBody3D
@export var scale_y_handle_static_body:StaticBody3D
@export var scale_z_handle_static_body:StaticBody3D
#sliding
@export var slide_x_handle_static_body:StaticBody3D
@export var slide_y_handle_static_body:StaticBody3D
@export var slide_z_handle_static_body:StaticBody3D
var handles_static_bodies:Array[StaticBody3D] = []
#endregion

var gizmo_distance_scale:float = 0.2

var targeted_handle:StaticBody3D

var last_targeted_handle:StaticBody3D

static var instance = null

#region built-ins 
func _ready() -> void:
	if instance == null:
		instance = self
	else:
		queue_free()
	await UIEditor.instance != null
	await UIEditor.instance.is_node_ready()	
	assign_arrays()
	connect_signals()
	reset()	
	enter_translate_mode()
	

func _exit_tree() -> void:
	disconnect_signals()
	if instance == self:
		instance = null

func _process(_delta: float) -> void:
	if not GameManager.current_level == GameManager.SCENES.WORLD_EDITOR || not GameManager.current_level == GameManager.SCENES.WORLD_EDITOR:
		return

	var cam_distance:float = global_position.distance_to(get_viewport().get_camera_3d().global_position)
	scale = Vector3(cam_distance, cam_distance, cam_distance)*gizmo_distance_scale
	

func _physics_process(delta: float) -> void:
	get_handle_target()
	update_handle_indication()
	
#endregion builtins

#region targeting 
func set_target(ob:Node3D):
	global_position = ob.global_position
	global_rotation = ob.global_rotation

## sends a raycast to layer 8 looking for gizmo handles. Assigns targeted_handle if found.
func get_handle_target():
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		return 
	var space_state = get_world_3d().direct_space_state
	var cam:Camera3D = get_viewport().get_camera_3d()
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end, HelperFunctions.get_layer_mask([8]))
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var target_result = space_state.intersect_ray(query) 
	
	if not target_result.is_empty():
		targeted_handle = target_result["collider"]
	else:
		targeted_handle = null
#endregion 

func assign_arrays()->void:
	handles= [
		# rotation
		rotate_x_handle,
		rotate_y_handle,
		rotate_z_handle,
		#translation
		translate_x_handle,
		translate_y_handle,
		translate_z_handle,
		#scaling
		scale_x_handle,
		scale_y_handle,
		scale_z_handle,
		#sliding
		slide_x_handle,
		slide_y_handle,
		slide_z_handle,
	]
	handles_static_bodies = [
		rotate_x_handle_static_body,
		rotate_y_handle_static_body,
		rotate_z_handle_static_body,
		#translation
		translate_x_handle_static_body,
		translate_y_handle_static_body,
		translate_z_handle_static_body,
		#scaling
		scale_x_handle_static_body,
		scale_y_handle_static_body,
		scale_z_handle_static_body,
		#sliding
		slide_x_handle_static_body,
		slide_y_handle_static_body,
		slide_z_handle_static_body,
	]
	
#region signals
func connect_signals()->void:
	UIEditor.instance.changed_transform_mode.connect(_on_transform_mode_changed)
	for handle:StaticBody3D in handles_static_bodies:
		handle.visibility_changed.connect(_on_visibility_changed.bind(handle))

		
func disconnect_signals()->void:
	#UIEditor.instance.changed_transform_mode.disconnect(_on_transform_mode_changed)
	for handle:StaticBody3D in handles_static_bodies:
		handle.visibility_changed.disconnect(_on_visibility_changed.bind(handle))
#endregion

#region mode change
func _on_transform_mode_changed(old_mode, new_mode):
	reset()
	match new_mode:
		UIEditor.instance.TranformMode.TRANSLATE:
			enter_translate_mode()
		UIEditor.instance.TranformMode.ROTATE:
			enter_rotate_mode()
		UIEditor.instance.TranformMode.SCALE:
			enter_scale_mode()
	
func reset()->void:
	for handle:MeshInstance3D in handles:
		handle.hide()

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

#region physics management
func _on_visibility_changed(handle:StaticBody3D)->void:
	# turn off physics for invisible items. Turn them on again when visible.
	if handle.is_visible_in_tree():
		handle.get_child(0).disabled = false
	else:
		handle.get_child(0).disabled = true
#endregion 

#region hover indictators
func _handle_mouse_entered(handle:StaticBody3D):
	set_handle_material_highlighted(handle.get_parent())

func _handle_mouse_exited(handle:StaticBody3D):
	set_handle_material_normal(handle.get_parent())

func update_handle_indication()->void:
	# CASE: Still hovering. Do nothing, return.
	if targeted_handle == last_targeted_handle:
		return
	# CASE: No target. Will return.
	if targeted_handle == null:
		# CASE: There was a previous target. Disable. Return.
		if last_targeted_handle != null:
			reset_handles()
			last_targeted_handle = null
		return	
	# CASE: New handle hovered. Highlight.
	if targeted_handle != null && last_targeted_handle == null:	
		set_handle_material_highlighted(targeted_handle.get_parent_node_3d())
		last_targeted_handle = targeted_handle
		return 
	# CASE: We've switched handles immediately without space in between.
	if targeted_handle != last_targeted_handle:
		reset_handles()
		set_handle_material_highlighted(targeted_handle.get_parent_node_3d())
		
	last_targeted_handle = targeted_handle

func set_handle_material_highlighted(handle:MeshInstance3D)->void:
	if handle.name.ends_with("_X"):
		handle.material_override = FLAT_RED_HIGHLIGHTED
	if handle.name.ends_with("_Y"):
		handle.material_override = FLAT_GREEN_HIGHLIGHTED
	if handle.name.ends_with("_Z"):
		handle.material_override = FLAT_BLUE_HIGHLIGHTED
		
func set_handle_material_normal(handle:MeshInstance3D)->void:
	if handle.name.ends_with("_X"):
		handle.material_override = FLAT_RED
	if handle.name.ends_with("_Y"):
		handle.material_override = FLAT_GREEN
	if handle.name.ends_with("_Z"):
		handle.material_override = FLAT_BLUE
func reset_handles():
	for handle in handles:
		set_handle_material_normal(handle)
#endregion 
