extends Node

## Main function for getting a grid point.
func get_grid_cell_center_point(pos:Vector3, cell_size:float)->Vector3:
	return pos.snappedf(cell_size)
