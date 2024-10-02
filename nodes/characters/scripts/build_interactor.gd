extends RayCast3D

class_name BuildInteractor

@export var current_cell_size:float = 5
var current_grid_point:Vector3 = Vector3.ZERO

@export var testing:bool = false

func _physics_process(delta: float) -> void:
	get_current_grid_point()

func get_current_grid_point():
	if is_colliding():
		current_grid_point = Grid.get_grid_cell_center_point(get_collision_point(), current_cell_size)
	
