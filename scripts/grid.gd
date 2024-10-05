extends Node

var current_grid_cell:GridCell = null

#region directionality
var n:Vector3:
	get:
		return current_grid_cell.get_cell_point(Types.CompassDirection.NORTH)
var e:Vector3:
	get:
		return current_grid_cell.get_cell_point(Types.CompassDirection.EAST)
var s:Vector3:
	get:
		return current_grid_cell.get_cell_point(Types.CompassDirection.SOUTH)
var w:Vector3:
	get:
		return current_grid_cell.get_cell_point(Types.CompassDirection.WEST)

var ne:Vector3:
	get:
		return current_grid_cell.get_cell_point(Types.CompassDirection.NORTH_EAST)
var se:Vector3:
	get:
		return current_grid_cell.get_cell_point(Types.CompassDirection.SOUTH_EAST)
var sw:Vector3:
	get:
		return current_grid_cell.get_cell_point(Types.CompassDirection.SOUTH_WEST)
var nw:Vector3:
	get:
		return current_grid_cell.get_cell_point(Types.CompassDirection.NORTH_WEST)
#endregion 

func _ready() -> void:
	current_grid_cell = GridCell.new(Vector3.ZERO, 4)

## Main function for getting a grid point.
func get_grid_cell_center_point(pos:Vector3, cell_size:float)->Vector3:
	var cell_center_point:Vector3 = pos.snappedf(cell_size)
	if current_grid_cell.cell_center_point != cell_center_point:
		update_current_grid_cell(cell_center_point, cell_size)
	return cell_center_point

func get_closest_anchor_point(pos:Vector3, modular_structure_type:Types.ModularStructureType = Types.ModularStructureType.NONE):
	return current_grid_cell.get_closest_anchor_point(pos, modular_structure_type)

func get_current_grid_point()->Vector3:
	return current_grid_cell.get_cell_point()

func get_current_cell_size():
	return current_grid_cell.get_cell_size()

func update_current_grid_cell(pos:Vector3, cell_size:float):
	current_grid_cell = GridCell.new(pos, cell_size)
	
