extends Node3D

@onready var builder_ray_cast_3d: RayCast3D = $BuilderRayCast3D
@onready var barrier_detector: Area3D = $BarrierDetector
@onready var hit_marker: Marker3D = $HitMarker
@export var marker_follow_speed:float = 0.5

const CONFIRMED_OVERLAY = preload("res://materials/world_interaction/confirmed_overlay.tres")
const ERROR_OVERLAY = preload("res://materials/world_interaction/error_overlay.tres")

var is_snap_mode_active = false

var is_in_item_placement_mode:bool = false

var last_can_place_status: bool = false
signal can_place_status_changed(old_value:bool, new_value:bool)


var target_position:Vector3 = Vector3.ZERO

#region placement positions
var placement_position_snapped:Vector3 = Vector3.ZERO
var placement_rotation_snapped:Vector3 = Vector3.ZERO
var place_snapped_transform:bool = false
#endregion 

@export var anchor:Node3D = null
var anchored_object:Node3D = null

var current_object_category:String = ""
var current_object_id:int = 0

var current_anchor_type:BuildObjectValidator.AnchorType = BuildObjectValidator.AnchorType.NONE


func _input(event: InputEvent) -> void:
	if not is_in_item_placement_mode:
		return
	if event.is_action_pressed("left_mouse_button"):
		place_item()
	

func _physics_process(_delta):
	if anchored_object == null:
		return
	snap_or_slide_on_target()

func remove_object(ob:Node)->void:
	ob.queue_free()

#region snapping

func snap_or_slide_on_target():
	if current_object_id == 0:
		return
	if builder_ray_cast_3d.is_colliding():	
		var build_object_validator:BuildObjectValidator = BuildObjectValidator.new(anchored_object, builder_ray_cast_3d.get_collider().get_parent())
		
		#var target_anchor_type:BuildObjectValidator.AnchorType = build_object_validator.get_anchor_type(builder_ray_cast_3d.get_collider().get_parent())
		
		if build_object_validator.is_compatible_target():
			snap_to_target()
		else:
			slide_to_target()

	else:
		hit_marker.hide()
	can_place()
	
func snap_to_target():	
	is_snap_mode_active = true
	if builder_ray_cast_3d.is_colliding():
		var collider: CollisionObject3D = builder_ray_cast_3d.get_collider()
		hit_marker.show()
		if anchored_object == null:
			return
		hit_marker.global_position = collider.global_position
		hit_marker.global_rotation = collider.global_rotation
		placement_position_snapped = collider.global_position
		placement_rotation_snapped = collider.global_rotation_degrees
		place_snapped_transform = true
	else:
		hit_marker.hide()	
		placement_position_snapped = Vector3.ZERO
		placement_rotation_snapped = Vector3.ZERO
		place_snapped_transform = false

func slide_to_target():	
	is_snap_mode_active = false
	if builder_ray_cast_3d.is_colliding():
		target_position = builder_ray_cast_3d.get_collision_point()
		hit_marker.show()
		hit_marker.global_position = target_position
		hit_marker.global_rotation_degrees = Vector3.ZERO
	else:
		hit_marker.hide()	
		
func enter_placement_mode(object_category:String, object_id:int):
	cancel_place_item()
	current_object_category = object_category
	current_object_id = object_id
	var ob:Node = ObjectIndex.spawn(object_category, object_id)
	if ob == null:
		return
	is_in_item_placement_mode = true	
	anchor_placement_object(ob)
	add_error_overlay()

#endregion snapping

#region placement
## puts the spawned object to be placed into the anchor
## necessary for moving the future placement of object.
## not to be confused with actual placement of object.
func anchor_placement_object(ob:Node3D):
	if ob == null: 
		return
	anchor.add_child(ob, true)
	ob.position = anchor.position
	ob.rotation = anchor.rotation
	anchored_object = ob
	#Check for an "anchors" anchors child and remove it. 
	for child in ob.get_children():
		if child.name.to_lower().begins_with("anchors"):
			child.queue_free()	 
	
	convert_active_object_to_holographic()
	set_raycast_collision_mask_for_placeable_object(anchored_object)

func place_item()->void:
	if not can_place():
		return	

	var placement_pos:Vector3 
	var placement_rot:Vector3
	if place_snapped_transform:
		placement_pos = placement_position_snapped
		placement_rot = placement_rotation_snapped
	else:
		placement_pos = anchored_object.global_position
		placement_rot = anchored_object.global_rotation_degrees
	
	var pos = ArgParser.string_argument_from_vector("--p", placement_pos)
	var rot = ArgParser.string_argument_from_vector("--r", placement_rot)
	var command:String = "/spawn {cat} {id} {p} {r}".format({"cat":current_object_category, "id":current_object_id, "p":pos, "r":rot})
	print(command)
	Cmd.cmd(command)
	
	convert_active_object_to_holographic(false)
	cancel_place_item()
	
func cancel_place_item():
	current_object_category = ""
	current_object_id = 0
	anchored_object = null
	for ob in anchor.get_children():
		ob.queue_free()
	
func convert_active_object_to_holographic(hographic:bool = true):	
	if anchored_object == null:
		return
	for child in anchored_object.get_children():
		if child.name == "BuildAreaOccupied":
			var build_area: Area3D = child
			build_area.monitorable = !hographic
			build_area.monitoring = !hographic
	remove_overlay()
	
func can_place() -> bool:		
	if anchored_object == null:
		update_last_can_place_status(false)
		return false
	
	if UI.instance.is_ui_blocking():
		update_last_can_place_status(false)
		return false
	
	if is_space_occupied():
		update_last_can_place_status(false)
		return false
	
	## since these first negative checks are done, now the last to make positive
	match current_anchor_type:
		BuildObjectValidator.AnchorType.FOUNDATION:
			update_last_can_place_status(true)
			return true
		
		_: #DEFAULT
			if is_snap_mode_active:
				update_last_can_place_status(true)
				return true
	
	update_last_can_place_status(false)
	return false
	
func update_last_can_place_status(current_can_place:bool):
	if current_can_place != last_can_place_status:		
		can_place_status_changed.emit(last_can_place_status, current_can_place)
	last_can_place_status = current_can_place

func _on_can_place_status_changed(_old_value:bool, new_value:bool) -> void:
	if new_value == true:
		add_confirmed_overlay()		
	else:		
		add_error_overlay()
	
#endregion placment

#region detection

func set_raycast_collision_mask_for_placeable_object(ob:Node) -> void:
	var build_object_validator:BuildObjectValidator = BuildObjectValidator.new(ob)
	var anchor_type:BuildObjectValidator.AnchorType = build_object_validator.get_current_object_anchor_type()
	current_anchor_type = anchor_type
	
	var detectable_layers: Array = build_object_validator.get_build_detection_collision_layers()
	
	for i in range(32):
		builder_ray_cast_3d.set_collision_mask_value(i+1, detectable_layers.has(i+1))

func add_error_overlay():
	if not is_object_anchored():
		return
	for child in anchored_object.get_children():
		if child is MeshInstance3D:
			child.material_overlay = ERROR_OVERLAY

func add_confirmed_overlay():
	if not is_object_anchored():
		return
	for child in anchored_object.get_children():
		if child is MeshInstance3D:
			child.material_overlay = CONFIRMED_OVERLAY

func remove_overlay():
	if not is_object_anchored():
		return
	for child in anchored_object.get_children():
		if child is MeshInstance3D:
			child.material_overlay = null

func is_space_occupied() -> bool:
	if not builder_ray_cast_3d.is_colliding():
		return false
	barrier_detector.global_position = builder_ray_cast_3d.get_collision_point()
	
	var objects_in_area: Array[Area3D] = barrier_detector.get_overlapping_areas()
	
	if not objects_in_area.is_empty():
		return true
	
	return false

func is_object_anchored()->bool:
	if anchored_object == null:
		return false
	return true

#endregion detection
