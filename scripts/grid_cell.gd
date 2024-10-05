
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

func get_anchor_points(modular_structure_type:Types.ModularStructureType = Types.ModularStructureType.NONE)->Array[Vector3]:
	var points:Array[Vector3] = []

	var point_center:Array[Vector3] = [
		cell_center_point,
	]

	var points_walls:Array[Vector3] = [
		cell_point_north,
		cell_point_east,
		cell_point_south,
		cell_point_west,
	]
	
	var points_pillars:Array[Vector3] = [
		cell_point_north_east,
		cell_point_south_east,
		cell_point_south_west,
		cell_point_north_west,
	]
	
	match modular_structure_type:
		Types.ModularStructureType.NONE:
			points = point_center + points_walls + points_pillars
		Types.ModularStructureType.FLOOR:
			points = point_center
		Types.ModularStructureType.WALL_1:
			points = points_walls
		Types.ModularStructureType.WALL_2:
			points = points_walls
		Types.ModularStructureType.PILLAR:
			points = points_pillars
		Types.ModularStructureType.INTERIOR_MODULE:
			points = point_center
	return points

## Gets the closest anchor point to the position supplied.
func get_closest_anchor_point(pos:Vector3, modular_structure_type:Types.ModularStructureType = Types.ModularStructureType.NONE)->Vector3:	
	var points:Array[Vector3] = get_anchor_points(modular_structure_type)	
	var closest_point:Vector3 = Vector3.ZERO
	var last_distance = 99999999	
	for point in points:
		if pos.distance_to(point) < last_distance:
			last_distance = pos.distance_to(point)
			closest_point = point	
	return closest_point
