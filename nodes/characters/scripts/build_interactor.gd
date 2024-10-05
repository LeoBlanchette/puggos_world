extends RayCast3D

class_name BuildInteractor

@export var current_cell_size:float = 4
var current_grid_point:Vector3 = Vector3.ZERO
var current_collision_point:Vector3 = Vector3.ZERO
var current_structure_type:Types.ModularStructureType = Types.ModularStructureType.NONE

## This is the representation of the placeable object.
@export var anchor:Marker3D 
var hologram:Node3D = null

@export var testing:bool = false

func _physics_process(delta: float) -> void:
	get_current_grid_point()
	position_anchor()

func get_current_grid_point():
	if is_colliding():
		current_collision_point = get_collision_point()
		current_grid_point = Grid.get_grid_cell_center_point(get_collision_point(), current_cell_size)

func position_anchor():
	var compatible_anchor_point:Vector3 = Grid.get_closest_anchor_point(current_collision_point, current_structure_type)
	anchor.global_position = compatible_anchor_point
	anchor.global_rotation_degrees = Vector3.ZERO

func clear_hologram():
	for child in anchor.get_children():
		child.queue_free()

func reset_hologram():
	hologram.basis = Basis.IDENTITY
	var sub_objects = HelperFunctions.get_all_children(hologram)
	for sub_object in sub_objects:
		if sub_object is StaticBody3D:
			sub_object.queue_free()

func anchor_hologram():
	clear_hologram()
	anchor.add_child(hologram)
	update_current_structure_type()
	reset_hologram()

func enter_placement_mode(object_category:String, object_id:int):
	var structure:Node3D  = ObjectIndex.object_index.get_structure(object_id)
	if structure == null:
		return
	hologram = structure.duplicate()
	anchor_hologram()
	
func update_current_structure_type():
	var structure_type_meta:String = hologram.get_meta("structure_type", "NONE")
	current_structure_type = Types.ModularStructureType.get(structure_type_meta)
	
