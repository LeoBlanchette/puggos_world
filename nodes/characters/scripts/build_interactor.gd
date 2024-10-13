extends RayCast3D

class_name BuildInteractor

var current_object_id:int = 0
var current_object_category:String = ""

@export var current_cell_size:float = 4
var current_grid_point:Vector3 = Vector3.ZERO
var current_collision_point:Vector3 = Vector3.ZERO
var current_structure_type:Types.ModularStructureType = Types.ModularStructureType.NONE
var last_sampled_grid_point:Vector3 = Vector3.ZERO

## This is the representation of the placeable object.
@export var anchor:Marker3D 
## This probes empty space when the raycaster is hitting nothing.
@onready var probe: Marker3D = $Probe
var hologram:Node3D = null
var hologram_last_postion:Vector3 = Vector3.ZERO
var hologram_last_rotation:Vector3 = Vector3.ZERO

@export var show_guides:bool = false

func _ready() -> void:
	PlayerInput.rotate_pressed.connect(rotate_hologram_90)
	PlayerInput.primary_action_pressed.connect(place_object)
	PlayerInput.alt_pressed.connect(toggle_guides)

func _physics_process(delta: float) -> void:
	get_current_grid_point()
	position_anchor()
	rotate_hologram()
	record_last_state()

func get_current_grid_point():
	if is_colliding():
		current_collision_point = get_collision_point()
	else:
		current_collision_point = probe.global_position
		
	current_grid_point = Grid.get_grid_cell_center_point(current_collision_point, current_cell_size)
	
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

func rotate_hologram_90():
	var rotate_amount:float = 90
	if hologram == null:
		return
	if current_structure_type == Types.ModularStructureType.WALL_1:
		rotate_amount = 180
	if current_structure_type == Types.ModularStructureType.WALL_2:
		rotate_amount = 180
	var new_rotation:float = hologram.rotation_degrees.y
	if new_rotation >= 360:
		new_rotation = 0
	hologram.rotation_degrees = Vector3(0, new_rotation+rotate_amount, 0)

func rotate_hologram():
	if hologram == null:
		return
	var compatible_anchor_point:Vector3 = Grid.get_closest_anchor_point(current_collision_point, current_structure_type)
	if last_sampled_grid_point != compatible_anchor_point:
		hologram.rotation_degrees = Vector3(0, Grid.get_wall_rotation(compatible_anchor_point), 0)
	last_sampled_grid_point = compatible_anchor_point

func record_last_state():
	if hologram == null:
		return
	hologram_last_postion = hologram.global_position
	hologram_last_rotation = hologram.global_rotation_degrees

func enter_placement_mode(object_category:String, object_id:int):
	current_object_category = object_category
	current_object_id = object_id
	var structure:Node3D  = ObjectIndex.object_index.get_structure(object_id)
	if structure == null:
		return
	hologram = structure.duplicate()
	anchor_hologram()

func place_object():
	if hologram == null:
		return
	if current_object_id == 0:
		return
	var placement_pos = hologram_last_postion.snappedf(0.1)
	var placement_rot = hologram_last_rotation.snappedf(0.1)
	var pos = ArgParser.string_argument_from_vector("--p", placement_pos)
	var rot = ArgParser.string_argument_from_vector("--r", placement_rot)
	var command:String = "/spawn {cat} {id} {p} {r}".format({"cat":current_object_category, "id":current_object_id, "p":pos, "r":rot})
	clear_hologram()
	Cmd.cmd(command)

func update_current_structure_type():
	var structure_type_meta:String = hologram.get_meta("structure_type", "NONE")
	current_structure_type = Types.ModularStructureType.get(structure_type_meta)
	
func toggle_guides():
	show_guides = !show_guides
