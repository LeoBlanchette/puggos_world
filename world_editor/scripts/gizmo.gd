extends Node3D

class_name EditorGizmo

const RAY_LENGTH:float = 1000

enum Axis{
	X,
	Y,
	Z,
}

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

#region rotate
var is_rotating:bool = false
var initial_rotation:Vector3 = Vector3.ZERO
var initial_transform:Transform3D = Transform3D.IDENTITY
var is_positive_normal:bool = true
var tmp_anchor:Node3D = null
#endregion

#region scale
var initial_scale:Vector3 = Vector3.ONE
var scale_line_initial_length:float = 0
var initial_edited_object_basis:Basis =Basis.IDENTITY
#endregion scale

## Keeps the gizmo sized consistently in viewport.
var gizmo_distance_scale:float = 0.2

var targeted_handle:StaticBody3D
var targeted_position:Vector3
var last_target_handle_name:String = ""

var last_targeted_handle:StaticBody3D

var target_object:Node3D = null

static var instance:EditorGizmo = null

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
func _on_object_selected(ob:Node3D)->void:
	set_target(ob)

func update_transform_space_mode():
	if Editor.instance.get_active_object() == null:
		return
	set_target(Editor.instance.edited_object)

func snap_to_active_object():
	if Editor.instance == null:
		return
	if Editor.instance.get_active_object() == null:
		return
	set_target(Editor.instance.get_active_object())


func set_target(ob:Node3D):
	if is_self_click(ob):
		return
	if is_transforming:
		return
	global_position = ob.global_position
	if use_local_space():
		global_rotation = ob.global_rotation
	else:
		global_rotation = Vector3.ZERO
	current_scale = ob.scale

func create_tmp_anchor()->Node3D:
	tmp_anchor = Node3D.new()
	tmp_anchor.name = "tmp_anchor"
	add_child(tmp_anchor)
	tmp_anchor.global_basis = Editor.instance.get_active_object().global_basis
	return tmp_anchor
	
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
	EditorInteractor.instance.object_selected.connect(_on_object_selected)
	for handle:StaticBody3D in handles_static_bodies:
		handle.visibility_changed.connect(_on_visibility_changed.bind(handle))
	Editor.instance.changed_transform_space_mode.connect(update_transform_space_mode)
	Editor.instance.object_transform_changed_ui.connect(snap_to_active_object)
		
func disconnect_signals()->void:
	#UIEditor.instance.changed_transform_mode.disconnect(_on_transform_mode_changed)
	for handle:StaticBody3D in handles_static_bodies:
		handle.visibility_changed.disconnect(_on_visibility_changed.bind(handle))
	Editor.instance.changed_transform_space_mode.disconnect(update_transform_space_mode)
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

func set_gizmo_to_clicked_space():
	var pos:Vector3
	var space_state = get_world_3d().direct_space_state
	var cam:Camera3D = get_viewport().get_camera_3d()
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var target_result:Dictionary = space_state.intersect_ray(query) 
	
	if not target_result.is_empty():
		pos = target_result["position"]
	else:
		pos = cam.project_position(mousepos, 1)
	global_position = pos

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
		initial_click_position = Vector3.ZERO
		initial_position = Vector3.ZERO
		initial_rotation = Vector3.ZERO
		initial_scale = Vector3.ZERO
		initial_basis = Basis.IDENTITY
		initial_mouse_click = Vector2.ZERO
		DrawEditorUI.instance.clear()
		is_rotating = false
		initial_transform = Transform3D.IDENTITY
		Editor.instance.set_action_text("")
		scale_line_initial_length = 0
		initial_edited_object_basis = Basis.IDENTITY
		if not use_local_space():
			global_rotation = Vector3.ZERO
		if tmp_anchor != null:
			tmp_anchor.queue_free()
		
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
			scale_on_axis(Axis.X)
		CurrentTransformType.SCALE_Y:
			scale_on_axis(Axis.Y)
		CurrentTransformType.SCALE_Z:
			scale_on_axis(Axis.Z)
		#SLIDE 
		CurrentTransformType.SLIDE_X:
			slide_on_axis(Axis.X)
		CurrentTransformType.SLIDE_Y:
			slide_on_axis(Axis.Y)
		CurrentTransformType.SLIDE_Z:
			slide_on_axis(Axis.Z)
			

func draw_guide_lines_translation(axis:Axis, origin:Vector3, destination:Vector3)->void:	
	var cam:Camera3D = get_viewport().get_camera_3d()
	
	var mouse_position_mark:Vector2 = get_viewport().get_mouse_position() 
	var destination_position_mark:Vector2 = cam.unproject_position(destination)
	var origin_mark:Vector2 = cam.unproject_position(origin)
	
	DrawEditorUI.instance.current_axis = axis
	
	DrawEditorUI.instance.guide_lines = [
		mouse_position_mark,
		destination_position_mark,
		origin_mark
	]

func draw_guide_lines_sliding(axis:Axis, origin:Vector3)->void:	
	var cam:Camera3D = get_viewport().get_camera_3d()
	
	var mouse_position_mark:Vector2 = get_viewport().get_mouse_position() 
	var origin_mark:Vector2 = cam.unproject_position(origin)
	
	DrawEditorUI.instance.current_axis = axis
	
	DrawEditorUI.instance.guide_lines_axis_only = [
		mouse_position_mark,
		origin_mark
	]


func draw_guide_lines_rotation(axis:Axis, rotation_start:Vector3, rotation_end:Vector3)->void:
	var cam:Camera3D = get_viewport().get_camera_3d()
	
	var rotation_start_mark:Vector2 = cam.unproject_position(rotation_start)
	var rotation_end_mark:Vector2 = cam.unproject_position(rotation_end)
	var origin_mark:Vector2 = cam.unproject_position(initial_position)
	
	DrawEditorUI.instance.current_axis = axis
	DrawEditorUI.instance.guide_lines_rotation = [
		rotation_start_mark,
		rotation_end_mark,
		origin_mark
	]
	

func get_translation_point(axis:Axis)->Vector3:
	var cam:Camera3D = get_viewport().get_camera_3d()
	var mouse_position:Vector2 = get_viewport().get_mouse_position() 
	
	# The mouse viewport position and normal in world coordinates
	var mouse_ray_normal:Vector3 = cam.project_ray_normal(mouse_position)
	var mouse_world_position:Vector3 = cam.project_position(mouse_position, 0.01)
	
	
	# The plane that the mouse will intersect with
	var plane_depth_guide_positive:Plane
	var plane_depth_guide_negative:Plane
	var plane_depth_guide_a:Vector3 # will be basis.x, y, or z
	var plane_depth_guide_b:Vector3 # ...etc
	var plane_depth_guide_c:Vector3

	# The secondary plane that will catch the axis intersection
	var plane_axis_guide_positive:Plane
	var plane_axis_guide_negative:Plane
	
	var depth_point:Vector3 = Vector3.ZERO
	var axis_point:Vector3 = Vector3.ZERO
	var sliding_action_text = ""
	match axis:
		Axis.X:
			if use_local_space():
				plane_depth_guide_a = initial_basis.z
				plane_depth_guide_b = initial_basis.y
				plane_depth_guide_c = initial_basis.y
				sliding_action_text = "Translating X axis local: (%3.3f, %3.3f, %3.3f). Distance: %3.3f"
			else:
				plane_depth_guide_a = Vector3.FORWARD
				plane_depth_guide_b = Vector3.UP
				plane_depth_guide_c = Vector3.UP
				sliding_action_text = "Translating X axis global: (%3.3f, %3.3f, %3.3f). Distance: %3.3f"
		Axis.Y:
			if use_local_space():
				plane_depth_guide_a = initial_basis.x
				plane_depth_guide_b = initial_basis.z
				plane_depth_guide_c = initial_basis.z
				sliding_action_text = "Translating Y axis local: (%3.3f, %3.3f, %3.3f). Distance: %3.3f"
			else:
				plane_depth_guide_a = Vector3.LEFT
				plane_depth_guide_b = Vector3.FORWARD
				plane_depth_guide_c = Vector3.FORWARD
				sliding_action_text = "Translating Y axis global: (%3.3f, %3.3f, %3.3f). Distance: %3.3f"
		Axis.Z:
			if use_local_space():
				plane_depth_guide_a = initial_basis.x
				plane_depth_guide_b = initial_basis.y
				plane_depth_guide_c = initial_basis.y
				sliding_action_text = "Translating Z axis local: (%3.3f, %3.3f, %3.3f). Distance: %3.3f"
			else:
				plane_depth_guide_a = Vector3.LEFT
				plane_depth_guide_b = Vector3.UP
				plane_depth_guide_c = Vector3.UP
				sliding_action_text = "Translating Z axis global: (%3.3f, %3.3f, %3.3f). Distance: %3.3f"
				
	plane_depth_guide_positive = Plane(plane_depth_guide_a, initial_position)
	plane_depth_guide_negative = Plane(-plane_depth_guide_a, initial_position)

	plane_axis_guide_positive = Plane(plane_depth_guide_b, initial_position)
	plane_axis_guide_negative = Plane(-plane_depth_guide_b, initial_position)
	
	var depth_point_positive = plane_depth_guide_positive.intersects_ray(mouse_world_position, mouse_ray_normal)
	var depth_point_negative = plane_depth_guide_negative.intersects_ray(mouse_world_position, mouse_ray_normal)

	if depth_point_positive != null:
		depth_point = depth_point_positive
	if depth_point_negative != null:
		depth_point = depth_point_negative
	
	var axis_point_positive = plane_axis_guide_positive.intersects_ray(depth_point, plane_depth_guide_c)
	var axis_point_negative = plane_axis_guide_negative.intersects_ray(depth_point, -plane_depth_guide_c)

	if axis_point_positive != null:
		axis_point = axis_point_positive
	if axis_point_negative != null:
		axis_point = axis_point_negative
	
	if axis_point == null:
		return Vector3.ZERO
	var distance:float = initial_position.distance_to(axis_point) 
	Editor.instance.set_action_text(sliding_action_text%[global_position.x, global_position.y, global_position.z, distance])
	return axis_point

func translate_to_destination(destination_point:Vector3)->void:
	if initial_click_position == Vector3.ZERO:
		initial_click_position = destination_point
	var offset:Vector3 = initial_position - initial_click_position
	global_position = destination_point + offset
	Editor.instance.object_translated.emit(initial_position, global_position)
		
	
func translate_on_x_axis()->void:
	var destination_point:Vector3 = get_translation_point(Axis.X)
	translate_to_destination(destination_point)
	draw_guide_lines_translation(Axis.X, initial_position, destination_point)
	
func translate_on_y_axis()->void:
	var destination_point:Vector3 = get_translation_point(Axis.Y)
	translate_to_destination(destination_point)
	draw_guide_lines_translation(Axis.Y, initial_position, destination_point)
	
func translate_on_z_axis()->void:
	var destination_point:Vector3 = get_translation_point(Axis.Z)
	translate_to_destination(destination_point)
	draw_guide_lines_translation(Axis.Z, initial_position, destination_point)

func get_rotation_target_point(axis:Axis)->Vector3:
	var cam:Camera3D = get_viewport().get_camera_3d()
	var mouse_position:Vector2 = get_viewport().get_mouse_position() 
	var projected_position:Vector3 = cam.project_position(mouse_position, cam.global_position.distance_to(global_position))
	if initial_click_position == Vector3.ZERO:
		initial_click_position = projected_position

	return projected_position

func rotate_to_target_point_global(axis:Axis, rotation_start:Vector3, rotation_end:Vector3)->void:
	if !is_rotating:
		is_rotating = true
		initial_rotation = rotation_degrees
		initial_transform = transform
		create_tmp_anchor()
	var cam:Camera3D = get_viewport().get_camera_3d()

	var rotation_start_mark:Vector2 = cam.unproject_position(rotation_start)
	var rotation_end_mark:Vector2 = cam.unproject_position(rotation_end)
	var origin_mark:Vector2 = cam.unproject_position(initial_position)	
	var starting_rotation_degrees:float = DrawEditorUI.instance.get_rotation_tracker_1_degrees(origin_mark, rotation_start_mark)
	var current_rotation_degrees:float = DrawEditorUI.instance.get_rotation_tracker_2_degrees(origin_mark, rotation_end_mark)
	
	var total_rotation_degrees:float = current_rotation_degrees-starting_rotation_degrees
	var t:Transform3D = initial_transform
	var rotating_action_amount:String
	match axis:
		Axis.X:
			if is_axis_facing_camera(Axis.X):
				total_rotation_degrees = -total_rotation_degrees
			t.basis = t.basis.rotated(Vector3.RIGHT, deg_to_rad(total_rotation_degrees))
			rotating_action_amount = "Rotating, X axis global: %3.3f degrees."%total_rotation_degrees
		Axis.Y:
			if is_axis_facing_camera(Axis.Y):
				total_rotation_degrees = -total_rotation_degrees
			t.basis = t.basis.rotated(Vector3.UP, deg_to_rad(total_rotation_degrees))
			rotating_action_amount = "Rotating Y axis global: %3.3f degrees."%total_rotation_degrees
		Axis.Z:
			if is_axis_facing_camera(Axis.Z):
				total_rotation_degrees = total_rotation_degrees
			t.basis = t.basis.rotated(Vector3.FORWARD, deg_to_rad(total_rotation_degrees))
			rotating_action_amount = "Rotating Z axis global: %3.3f degrees."%total_rotation_degrees
	global_basis = t.basis
	Editor.instance.set_action_text(rotating_action_amount)
	Editor.instance.object_rotated.emit(initial_rotation, tmp_anchor.global_rotation_degrees)
	
func rotate_to_target_point_local(axis:Axis, rotation_start:Vector3, rotation_end:Vector3)->void:
	if !is_rotating:
		is_rotating = true
		initial_rotation = rotation_degrees
		initial_transform = global_transform
	
	var cam:Camera3D = get_viewport().get_camera_3d()
	
	var rotation_start_mark:Vector2 = cam.unproject_position(rotation_start)
	var rotation_end_mark:Vector2 = cam.unproject_position(rotation_end)
	var origin_mark:Vector2 = cam.unproject_position(initial_position)	
	var starting_rotation_degrees:float = DrawEditorUI.instance.get_rotation_tracker_1_degrees(origin_mark, rotation_start_mark)
	var current_rotation_degrees:float = DrawEditorUI.instance.get_rotation_tracker_2_degrees(origin_mark, rotation_end_mark)
	
	var total_rotation_degrees:float = current_rotation_degrees-starting_rotation_degrees
	var t:Transform3D = initial_transform
	var rotating_action_amount:String
	match axis:
		Axis.X:
			var rotation_x:float = initial_transform.basis.get_rotation_quaternion().x + total_rotation_degrees
			if is_axis_facing_camera(Axis.X):
				rotation_x = -rotation_x
			t.basis = t.basis.rotated(initial_transform.basis.x.normalized(), deg_to_rad(rotation_x))
			rotating_action_amount = "Rotating, X axis local: %3.3f degrees."%rotation_x
		Axis.Y:
			var rotation_y:float = initial_transform.basis.get_rotation_quaternion().y + total_rotation_degrees
			if is_axis_facing_camera(Axis.Y):
				rotation_y = -rotation_y
			t.basis = t.basis.rotated(initial_transform.basis.y.normalized(), deg_to_rad(rotation_y))
			rotating_action_amount = "Rotating Y axis local: %3.3f degrees."%rotation_y
		Axis.Z:
			var rotation_z:float = initial_transform.basis.get_rotation_quaternion().z + total_rotation_degrees
			if is_axis_facing_camera(Axis.Z):
				rotation_z = -rotation_z
			t.basis = t.basis.rotated(initial_transform.basis.z.normalized(), deg_to_rad(rotation_z))
			rotating_action_amount = "Rotating Z axis local: %3.3f degrees."%rotation_z
	global_basis = t.basis
	Editor.instance.set_action_text(rotating_action_amount)
	Editor.instance.object_rotated.emit(initial_rotation, rotation_degrees)

func rotate_on_axis(axis:String)->void:
	
	match axis:
		"X":			
			var target_point:Vector3 = get_rotation_target_point(Axis.X)
			if use_local_space():
				rotate_to_target_point_local(Axis.X, initial_click_position, target_point)
			else:
				rotate_to_target_point_global(Axis.X, initial_click_position, target_point)
			draw_guide_lines_rotation(Axis.X, initial_click_position, target_point)
		"Y":
			var target_point:Vector3 = get_rotation_target_point(Axis.X)
			if use_local_space():
				rotate_to_target_point_local(Axis.Y, initial_click_position, target_point)
			else:
				rotate_to_target_point_global(Axis.Y, initial_click_position, target_point)
			draw_guide_lines_rotation(Axis.Y, initial_click_position, target_point)
		"Z":
			var target_point:Vector3 = get_rotation_target_point(Axis.X)
			if use_local_space():
				rotate_to_target_point_local(Axis.Z, initial_click_position, target_point)
			else:
				rotate_to_target_point_global(Axis.Z, initial_click_position, target_point)
			draw_guide_lines_rotation(Axis.Z, initial_click_position, target_point)
			
func slide_on_axis(axis:Axis)->void:
	var cam:Camera3D = get_viewport().get_camera_3d()
	var mouse_position:Vector2 = get_viewport().get_mouse_position() 
	
	# The mouse viewport position and normal in world coordinates
	var mouse_ray_normal:Vector3 = cam.project_ray_normal(mouse_position)
	var mouse_world_position:Vector3 = cam.project_position(mouse_position, 0.01)
	
	var plane_depth_guide_positive:Plane
	var plane_depth_guide_negative:Plane
	
	var plane_depth_guide:Vector3
	var current_axis:Axis
	match axis:
		Axis.X:
			if use_local_space():
				plane_depth_guide = global_basis.x
			else: 
				plane_depth_guide = Vector3.LEFT
			current_axis=Axis.X
		Axis.Y:
			if use_local_space():
				plane_depth_guide = global_basis.y
			else:
				plane_depth_guide = Vector3.UP
			current_axis=Axis.Y
		Axis.Z:
			if use_local_space():
				plane_depth_guide = global_basis.z
			else:
				plane_depth_guide = Vector3.FORWARD
			current_axis=Axis.Z
	
	plane_depth_guide_positive = Plane(plane_depth_guide, global_position)
	plane_depth_guide_negative = Plane(-plane_depth_guide, global_position)
	
	var depth_point_positive = plane_depth_guide_positive.intersects_ray(mouse_world_position, mouse_ray_normal)
	var depth_point_negative = plane_depth_guide_negative.intersects_ray(mouse_world_position, mouse_ray_normal)
	
	var depth_point:Vector3 = Vector3.ZERO
	
	if depth_point_positive != null:
		depth_point = depth_point_positive
	if depth_point_negative != null:
		depth_point = depth_point_negative
	
	if initial_position == Vector3.ZERO:
		initial_position = depth_point

	translate_to_destination(depth_point)
	draw_guide_lines_sliding(current_axis,initial_position)
	var slide_distance:float = initial_position.distance_to(global_position)
	var sliding_action_text = "Sliding (%3.3f, %3.3f, %3.3f). Distance: %3.3f"
	Editor.instance.set_action_text(sliding_action_text%[global_position.x,global_position.y,global_position.z,slide_distance])


func scale_on_axis(axis:Axis)->void:
	if Editor.instance.edited_object == null:
		return
	if initial_edited_object_basis == Basis.IDENTITY:
		initial_edited_object_basis = Editor.instance.edited_object.basis
	var cam:Camera3D = get_viewport().get_camera_3d()
	var mouse_position:Vector2 = get_viewport().get_mouse_position() 
	
	# The mouse viewport position and normal in world coordinates
	var mouse_ray_normal:Vector3 = cam.project_ray_normal(mouse_position)
	var mouse_world_position:Vector3 = cam.project_position(mouse_position, 0.01)
	
	var plane_depth_guide_positive:Plane
	var plane_depth_guide_negative:Plane
	
	var plane_depth_guide:Vector3
	var current_axis:Axis
	var scaling_text:String = ""
	var space_text:String
	if use_local_space():
		space_text = "local"
	else:
		space_text = "global"
	match axis:
		Axis.X:
			if use_local_space():
				plane_depth_guide = global_basis.z
			else:
				plane_depth_guide = Vector3.FORWARD
			current_axis=Axis.X
			scaling_text = "Scaling X axis %s (%3.3f, %3.3f, %3.3f) by %3.3f percent"
		Axis.Y:
			if use_local_space():				
				plane_depth_guide = global_basis.y
			else:
				plane_depth_guide = Vector3.UP
			current_axis=Axis.Y
			scaling_text = "Scaling Y axis %s (%3.3f, %3.3f, %3.3f) by %3.3f percent"
		Axis.Z:
			if use_local_space():				
				plane_depth_guide = global_basis.x
			else:
				plane_depth_guide = Vector3.RIGHT
			current_axis=Axis.Z
			scaling_text = "Scaling Z axis %s (%3.3f, %3.3f, %3.3f) by %3.3f percent"
	
	plane_depth_guide_positive = Plane(plane_depth_guide, global_position)
	plane_depth_guide_negative = Plane(-plane_depth_guide, global_position)
	
	var depth_point_positive = plane_depth_guide_positive.intersects_ray(mouse_world_position, mouse_ray_normal)
	var depth_point_negative = plane_depth_guide_negative.intersects_ray(mouse_world_position, mouse_ray_normal)
	
	var depth_point:Vector3 = Vector3.ZERO
	
	if depth_point_positive != null:
		depth_point = depth_point_positive
	if depth_point_negative != null:
		depth_point = depth_point_negative
	
	if initial_position == Vector3.ZERO:
		initial_position = depth_point

	if scale_line_initial_length == 0:
		scale_line_initial_length = global_position.distance_to(depth_point)

	var scale_line_current_length:float = global_position.distance_to(depth_point)
	var scale_factor:float = 1.0/scale_line_initial_length
	var scale_amount:float = scale_factor * scale_line_current_length
	var new_basis:Basis = initial_edited_object_basis
	match axis:
		Axis.X:
			if use_local_space():
				new_basis.x = initial_edited_object_basis.x * scale_amount
			else:
				new_basis.x = Vector3.LEFT * -scale_amount
		Axis.Y:
			if use_local_space():
				new_basis.y = initial_edited_object_basis.y * scale_amount
			else:
				new_basis.y = Vector3.UP * scale_amount
		Axis.Z:
			if use_local_space():
				new_basis.z = initial_edited_object_basis.z * scale_amount
			else:
				new_basis.z = Vector3.FORWARD * -scale_amount

	draw_guide_lines_sliding(current_axis,initial_position)
	var scale_distance:float = initial_position.distance_to(global_position)
	scaling_text = scaling_text%[space_text, new_basis.get_scale().x, new_basis.get_scale().y, new_basis.get_scale().z, scale_amount]
	
	Editor.instance.set_action_text(scaling_text)
	Editor.instance.object_scaled.emit(initial_scale, new_basis.get_scale())

func is_axis_facing_camera(axis:Axis)->bool:
	var cam:Camera3D = get_viewport().get_camera_3d()
	var mouse_position:Vector2 = get_viewport().get_mouse_position() 
	var mouse_world_position:Vector3 = cam.project_position(mouse_position, 0.01)
	
	var normal_extended_position:Vector3
	
	match axis:
		Axis.X:
			normal_extended_position = global_position + global_basis.x*0.1
			#DrawEditorUI.instance.arbitrary_line = [cam.unproject_position(global_position), cam.unproject_position(normal_extended_position)]
		Axis.Y:
			normal_extended_position = global_position + global_basis.y*0.1
		Axis.Z:
			normal_extended_position = global_position + global_basis.z*0.1
	
	var extended_distance:float = mouse_world_position.distance_to(normal_extended_position)
	var object_distance:float = mouse_world_position.distance_to(global_position)
	
	if(extended_distance < object_distance):
		return true
	
	return false
	
func use_local_space()->bool:
	if Editor.instance.current_transform_space_mode == Editor.CurrentTransformSpaceMode.LOCAL:
		return true
	return false


#endregion 
