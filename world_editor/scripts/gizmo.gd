extends Node3D

class_name EditorGizmo

const RAY_LENGTH:float = 1000


enum CurrentTransformType{
	NONE,
	#translation
	TRANSLATE_X,
	TRANSLATE_Y,
	TRANSLATE_Z,
	#rotation
	ROTATE_X,
	ROTATE_Y,
	ROTATE_Z,
	#scaling
	SCALE_X,
	SCALE_Y,
	SCALE_Z,
	#sliding
	SLIDE_X,
	SLIDE_Y,
	SLIDE_Z,
}

var current_transform_type:CurrentTransformType = CurrentTransformType.NONE

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

#region active transforming variables
var is_attempting_drag:bool = false
var is_transforming:bool = false
var current_scale:Vector3 = Vector3.ONE
var initial_click_position:Vector3 = Vector3.ZERO
var initial_mouse_click:Vector2 = Vector2.ZERO
#endregion

#region translate
var initial_position:Vector3 = Vector3.ZERO
var initial_basis:Basis = Basis.IDENTITY
#endregion 

## Keeps the gizmo sized consistently in viewport.
var gizmo_distance_scale:float = 0.2

var targeted_handle:StaticBody3D
var last_target_handle_name:String = ""

var last_targeted_handle:StaticBody3D

var target_object:Node3D = null

static var instance = null

#region built-ins 
func _ready() -> void:
	if instance == null:
		instance = self
	else:
		queue_free()
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
	attempt_transform()

func _input(event: InputEvent) -> void:
	detect_transform_action(event)


#endregion builtins

#region targeting 
func set_target(ob:Node3D):
	if is_self_click(ob):
		return
	if is_transforming:
		return
	global_position = ob.global_position
	global_rotation = ob.global_rotation
	current_scale = ob.scale

## sends a raycast to layer 8 looking for gizmo handles. Assigns targeted_handle if found.
func get_handle_target():
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		return 
	if is_transforming:
		return
	var space_state = get_world_3d().direct_space_state
	var cam:Camera3D = get_viewport().get_camera_3d()
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end, HelperFunctions.get_layer_mask([9]))
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var target_result:Dictionary = space_state.intersect_ray(query) 
	
	if not target_result.is_empty() && target_result["collider"].get_parent() != null:
		targeted_handle = target_result["collider"]
		last_target_handle_name = targeted_handle.get_parent().name
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
	
func is_self_click(ob:Node3D)->bool:
	for handle in handles_static_bodies:
		if handle.get_rid() == ob.get_rid():
			return true
	return false

#region signals
func connect_signals()->void:
	Editor.instance.changed_transform_mode.connect(_on_transform_mode_changed)
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
		Editor.instance.TranformMode.TRANSLATE:
			enter_translate_mode()
		Editor.instance.TranformMode.ROTATE:
			enter_rotate_mode()
		Editor.instance.TranformMode.SCALE:
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

func remove():
	queue_free()
	
func detect_transform_action(event:InputEvent)->void:	
	if event.is_action_released("left_mouse_button"):
		is_attempting_drag = false
		trigger_transform_operation(false)
	if event.is_action_pressed("left_mouse_button"):
		is_attempting_drag = true
	if event.is_action_pressed("left_mouse_button") && targeted_handle != null:
		trigger_transform_operation(true)
		


func trigger_transform_operation(do_transform:bool):
	is_transforming = do_transform
	if !do_transform:
		reset_transform_operation()
		

func reset_transform_operation()->void:
		initial_position = Vector3.ZERO
		initial_basis = Basis.IDENTITY
		initial_mouse_click = Vector2.ZERO
		DrawEditorUI.instance.clear()
		pass

		
func attempt_transform():	
	if not is_transforming:
		current_transform_type = CurrentTransformType.NONE
		return
	match last_target_handle_name:
		#TRANSLATION
		"Translate_X":
			current_transform_type = CurrentTransformType.TRANSLATE_X
		"Translate_Y":
			current_transform_type = CurrentTransformType.TRANSLATE_Y
		"Translate_Z":
			current_transform_type = CurrentTransformType.TRANSLATE_Z
		#ROTATION
		"Rotate_X":
			current_transform_type = CurrentTransformType.ROTATE_X
		"Rotate_Y":
			current_transform_type = CurrentTransformType.ROTATE_Y
		"Rotate_Z":
			current_transform_type = CurrentTransformType.ROTATE_Z
		#SCALING
		"Scale_X":
			current_transform_type = CurrentTransformType.SCALE_X
		"Scale_Y":
			current_transform_type = CurrentTransformType.SCALE_Y
		"Scale_Z":
			current_transform_type = CurrentTransformType.SCALE_Z
		#SLIDING
		"Slide_X":
			current_transform_type = CurrentTransformType.SLIDE_X
		"Slide_Y":
			current_transform_type = CurrentTransformType.SLIDE_Y
		"Slide_Z":
			current_transform_type = CurrentTransformType.SLIDE_Z
		#DEFAULT
		_:
			current_transform_type = CurrentTransformType.NONE
			
	if current_transform_type == CurrentTransformType.NONE:
		return
	if initial_position == Vector3.ZERO:
		initial_position = global_position
	if initial_basis == Basis.IDENTITY:
		initial_basis = basis
	if initial_mouse_click == Vector2.ZERO:
		initial_mouse_click = get_viewport().get_mouse_position()
	do_transform()

func do_transform():		
	match current_transform_type:
		#TRANSLATE 
		CurrentTransformType.TRANSLATE_X:
			translate_on_x_axis()
		CurrentTransformType.TRANSLATE_Y:
			translate_on_y_axis()
		CurrentTransformType.TRANSLATE_Z:
			translate_on_z_axis()
		#ROTATE 
		CurrentTransformType.ROTATE_X:
			rotate_on_axis("X")
		CurrentTransformType.ROTATE_Y:
			rotate_on_axis("Y")
		CurrentTransformType.ROTATE_Z:
			rotate_on_axis("Z")
		#SCALE 
		CurrentTransformType.SCALE_X:
			scale_on_axis("X")
		CurrentTransformType.SCALE_Y:
			scale_on_axis("Y")
		CurrentTransformType.SCALE_Z:
			scale_on_axis("Z")
		#SLIDE 
		CurrentTransformType.SLIDE_X:
			pass
		CurrentTransformType.SLIDE_Y:
			pass
		CurrentTransformType.SLIDE_Z:
			pass
			

func draw_stretch_line()->void:
	DrawEditorUI.instance.stretch_line = [initial_mouse_click, get_viewport().get_mouse_position()]
	

func get_ray_intersection_point_for_axis(from:Vector3, dir:Vector3)->Vector3:
	var cam:Camera3D = get_viewport().get_camera_3d()
	var mouse_position:Vector2 = get_viewport().get_mouse_position()
	var viewport_size:Vector2 = get_viewport().size
	
	var point:Vector3 = cam.project_position(mouse_position, cam.global_position.distance_to(global_position))
	var plane:Plane = Plane(-dir, point)
	
	var intersection_point = plane.intersects_ray(from, dir)
	if intersection_point == null:
		return Vector3.ZERO
	return intersection_point

func translate_on_x_axis()->void:
	var intersection_point:Vector3 = get_ray_intersection_point_for_axis(-basis.x * 100000, basis.x)
	global_position = intersection_point
	draw_stretch_line()
	
func translate_on_y_axis()->void:
	var intersection_point:Vector3 = get_ray_intersection_point_for_axis(-basis.y * 100000, basis.y)
	global_position = intersection_point
	draw_stretch_line()
	
func translate_on_z_axis()->void:
	var intersection_point:Vector3 = get_ray_intersection_point_for_axis(-basis.z * 100000, basis.z)
	global_position = intersection_point
	draw_stretch_line()
	
func scale_on_axis(axis:String)->void:
	
	match axis:
		"X":
			pass
		"Y":
			pass
		"Z":
			pass
	
	#get_child(0).set_scale(current_scale)
func rotate_on_axis(axis:String)->void:
	
	match axis:
		"X":			
			pass
		"Y":
			pass
		"Z":
			pass
			
			


#endregion 
