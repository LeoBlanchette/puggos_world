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

#region gizmo guides
const GUIDE_XY = preload("res://world_editor/helpers/guide_xy.tscn")
const GUIDE_XZ = preload("res://world_editor/helpers/guide_xz.tscn")
const GUIDE_YZ = preload("res://world_editor/helpers/guide_yz.tscn")
var gizmo_guide_xy:Area3D = null
var gizmo_guide_xz:Area3D = null
var gizmo_guide_yz:Area3D = null
var gizmo_guides_active:bool = false
#endregion 

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
var move_to_pos_1:Vector3 = Vector3.ZERO
var move_to_pos_2:Vector3 = Vector3.ZERO
var move_offset:Vector3 = Vector3.ZERO
var starting_screen_coordinates = Vector2.ZERO
var current_screen_coordinates = Vector2.ZERO
var current_scale:Vector3 = Vector3.ONE
var starting_rotation:Vector3 = Vector3.ZERO
#endregion

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
		remove_gizmo_guide()
		move_to_pos_1 = Vector3.ZERO
		move_to_pos_2 = Vector3.ZERO
		move_offset = Vector3.ZERO
		starting_screen_coordinates = Vector2.ZERO
		current_screen_coordinates = Vector2.ZERO
		starting_rotation = Vector3.ZERO
		
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
	do_transform()

func set_gizmo_guide(gizmo_guides:Array)->void:
	if gizmo_guides_active:
		return
	
	if gizmo_guides.has("XY"):
		gizmo_guide_xy = GUIDE_XY.instantiate()
	if gizmo_guides.has("XZ"):
		gizmo_guide_xz = GUIDE_XZ.instantiate()
	if gizmo_guides.has("YZ"):
		gizmo_guide_yz = GUIDE_YZ.instantiate()
	
	if gizmo_guide_xy != null:
		get_parent().add_child(gizmo_guide_xy)
		gizmo_guide_xy.global_position = global_position
		
	if gizmo_guide_xz != null:
		get_parent().add_child(gizmo_guide_xz)
		gizmo_guide_xz.global_position = global_position
		
	if gizmo_guide_yz != null:
		get_parent().add_child(gizmo_guide_yz)
		gizmo_guide_yz.global_position = global_position

	gizmo_guides_active = true

func remove_gizmo_guide()->void:
	if gizmo_guide_xy != null:
		gizmo_guide_xy.queue_free()
		gizmo_guide_xy = null	
	if gizmo_guide_xz != null:
		gizmo_guide_xz.queue_free()
		gizmo_guide_xz = null	
	if gizmo_guide_yz != null:
		gizmo_guide_yz.queue_free()
		gizmo_guide_yz = null	
	
	gizmo_guides_active = false
	
func do_transform():	
	
	match current_transform_type:
		#TRANSLATE 
		CurrentTransformType.TRANSLATE_X:
			set_gizmo_guide(["XY", "XZ"])
		CurrentTransformType.TRANSLATE_Y:
			set_gizmo_guide(["XY", "YZ"])
		CurrentTransformType.TRANSLATE_Z:
			set_gizmo_guide(["XZ", "YZ"])
		#ROTATE 
		CurrentTransformType.ROTATE_X:
			set_gizmo_guide(["YZ"])
		CurrentTransformType.ROTATE_Y:
			set_gizmo_guide(["XZ"])
		CurrentTransformType.ROTATE_Z:
			set_gizmo_guide(["XY"])
		#SCALE 
		CurrentTransformType.SCALE_X:
			set_gizmo_guide(["XY"])
		CurrentTransformType.SCALE_Y:
			set_gizmo_guide(["YZ"])
		CurrentTransformType.SCALE_Z:
			set_gizmo_guide(["XZ"])
		#SLIDE 
		CurrentTransformType.SLIDE_X:
			set_gizmo_guide(["YZ"])
		CurrentTransformType.SLIDE_Y:
			set_gizmo_guide(["XZ"])
		CurrentTransformType.SLIDE_Z:
			set_gizmo_guide(["XY"])
	# FIRST HIT TO ACCESS FIRST GIZMO GUIDE
	var space_state = get_world_3d().direct_space_state
	var cam:Camera3D = get_viewport().get_camera_3d()
	var mousepos = get_viewport().get_mouse_position()
	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end, HelperFunctions.get_layer_mask([10]))
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var info:Dictionary = space_state.intersect_ray(query) 
		
	if not info.is_empty():
		move_to_pos_1 = info["position"]
	if move_offset == Vector3.ZERO: #this is set once and does not change for duration. Resets to Vector3.Zero after operation.
		move_offset = global_position
	if starting_screen_coordinates == Vector2.ZERO:
		starting_screen_coordinates = get_viewport().get_mouse_position()
	if starting_rotation == Vector3.ZERO:
		starting_rotation = global_rotation_degrees
	current_screen_coordinates = get_viewport().get_mouse_position()
	
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
			position = move_to_pos_1
		CurrentTransformType.SLIDE_Y:
			position = move_to_pos_1
		CurrentTransformType.SLIDE_Z:
			position = move_to_pos_1
			

func translate_on_x_axis()->void:
	var space_state = get_world_3d().direct_space_state
	gizmo_guide_xz.collision_layer = HelperFunctions.get_layer_mask([11])
	var second_query = PhysicsRayQueryParameters3D.create(move_to_pos_1+Vector3(0, 50000, 0), move_to_pos_1+Vector3(0, -100000, 0), HelperFunctions.get_layer_mask([11]))
	second_query.collide_with_areas = true
	second_query.collide_with_bodies = false
	var second_info:Dictionary = space_state.intersect_ray(second_query) 
	if not second_info.is_empty():
		move_to_pos_1 = second_info["position"]
	if move_to_pos_1 != Vector3.ZERO:
		position = move_to_pos_1 - move_offset
		
func translate_on_y_axis()->void:
	var space_state = get_world_3d().direct_space_state
	gizmo_guide_yz.collision_layer = HelperFunctions.get_layer_mask([11])
	var second_query = PhysicsRayQueryParameters3D.create(move_to_pos_1+Vector3(50000, 0, 0), move_to_pos_1+Vector3(-100000, 0, 0), HelperFunctions.get_layer_mask([11]))
	second_query.collide_with_areas = true
	second_query.collide_with_bodies = false
	var second_info:Dictionary = space_state.intersect_ray(second_query) 
	if not second_info.is_empty():
		move_to_pos_1 = second_info["position"]
	if move_to_pos_1 != Vector3.ZERO:
		position = move_to_pos_1
		
func translate_on_z_axis()->void:
	var space_state = get_world_3d().direct_space_state
	gizmo_guide_yz.collision_layer = HelperFunctions.get_layer_mask([11])
	var second_query = PhysicsRayQueryParameters3D.create(move_to_pos_1+Vector3(50000, 0, 0), move_to_pos_1+Vector3(-100000, 0, 0), HelperFunctions.get_layer_mask([11]))
	second_query.collide_with_areas = true
	second_query.collide_with_bodies = false
	var second_info:Dictionary = space_state.intersect_ray(second_query) 
	if not second_info.is_empty():
		move_to_pos_1 = second_info["position"]
	if move_to_pos_1 != Vector3.ZERO:
		position = move_to_pos_1
		
func scale_on_axis(axis:String)->void:
	var distance:float = move_to_pos_1.distance_to(position)
	match axis:
		"X":
			current_scale = Vector3(distance, current_scale.y, current_scale.z)
		"Y":
			current_scale = Vector3(current_scale.x, distance, current_scale.z)
		"Z":
			current_scale = Vector3(current_scale.x, current_scale.y, distance)
	
	#get_child(0).set_scale(current_scale)
func rotate_on_axis(axis:String)->void:
	var distance:float = move_to_pos_1.distance_to(move_offset)
	
	match axis:
		"X":			
			pass
		"Y":
			pass
		"Z":
			pass
			
			


#endregion 
