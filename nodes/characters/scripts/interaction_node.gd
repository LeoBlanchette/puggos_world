extends Node3D

class_name InteractionNode

@export var interaction_ray_cast_3d: RayCast3D
@export var marker_3d: Marker3D 

static var focused_point:Vector3 = Vector3.ZERO
static var focused_object:Node = null
static var focused_collider:CollisionObject3D = null

static var instance = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if instance == null:
		instance = self
	else: 
		queue_free()

func _exit_tree() -> void:
	if instance == self:
		instance == null

func _physics_process(delta: float) -> void:
	update_collision_point()

func update_collision_point():
	if interaction_ray_cast_3d.is_colliding():
		focused_point = interaction_ray_cast_3d.get_collision_point()
		var focused_object_hit:Node3D = interaction_ray_cast_3d.get_collider()
		if focused_object_hit  != null:
			if focused_object_hit.owner != null:
				focused_object = focused_object_hit.owner
			else:
				focused_object = focused_object_hit
			focused_collider = interaction_ray_cast_3d.get_collider()
	else:
		focused_point = Vector3.ZERO

func get_focused_point()->Vector3:
	return focused_point
	
func get_focused_object()->Node3D:
	if not is_instance_valid(focused_object):
		return null
	return focused_object

func get_focused_object_position()->Vector3:
	if get_focused_object() == null:
		return Vector3.ZERO
	return get_focused_object().position

func get_focused_collider()->CollisionObject3D:
	if not is_instance_valid(focused_collider):
		return null
	return focused_collider

func is_focused()->bool:
	if focused_point == Vector3.ZERO:
		return false
	return true

## Returns the name of the mod assigned in meta data. Empty if not assigned.
func get_meta_name()->String:
	return get_focused_object().get_meta("name", "")
