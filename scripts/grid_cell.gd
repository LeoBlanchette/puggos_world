
class_name GridCell

var cell_size:float
var cell_size_half:float

var cell_center_point:Vector3
var cell_point_north:Vector3
var cell_point_north_east:Vector3
var cell_point_east:Vector3
var cell_point_south_east:Vector3
var cell_point_south:Vector3
var cell_point_south_west:Vector3
var cell_point_west:Vector3
var cell_point_north_west:Vector3

func _init(_cell_center_point:Vector3, _cell_size:float):
	cell_center_point = _cell_center_point
	cell_size = _cell_size
	cell_size_half = _cell_size / 2
	
	cell_point_north = cell_center_point + Vector3.RIGHT * cell_size_half
	cell_point_east = cell_center_point + Vector3.BACK * cell_size_half
	cell_point_south = cell_center_point + Vector3.LEFT * cell_size_half
	cell_point_west = cell_center_point + Vector3.FORWARD * cell_size_half
	
	cell_point_north_east = cell_point_north + Vector3.BACK * cell_size_half
	cell_point_south_east = cell_point_east + Vector3.LEFT * cell_size_half
	cell_point_south_west = cell_point_south + Vector3.FORWARD * cell_size_half
	cell_point_north_west = cell_point_west + Vector3.RIGHT * cell_size_half

func get_cell_size()->float:
	return cell_size

## Returns a cell point in a cardinal direction. If none is supplied, then returns the center point.
func get_cell_point(direction:Types.CompassDirection = Types.CompassDirection.NONE)->Vector3:
	match direction:
		Types.CompassDirection.NONE:
			return cell_center_point
		Types.CompassDirection.NORTH:
			return cell_point_north
		Types.CompassDirection.EAST:
			return cell_point_east
		Types.CompassDirection.SOUTH:
			return cell_point_south
		Types.CompassDirection.WEST:
			return cell_point_west
		Types.CompassDirection.NORTH_EAST:
			return cell_point_north_east
		Types.CompassDirection.SOUTH_EAST:
			return cell_point_south_east
		Types.CompassDirection.SOUTH_WEST:
			return cell_point_south_west
		Types.CompassDirection.NORTH_WEST:
			return cell_point_north_west
		_:
			return cell_center_point
	return cell_center_point
