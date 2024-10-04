extends Node2D
## For visualizing where the grid points are operative. 

@onready var build_interactor: BuildInteractor = $".."

@export var color_center_point:Color = Color.RED
@export var color_border_lines:Color = Color.GREEN
@export var color_wall_points:Color = Color.ORANGE
@export var color_pillar_points:Color = Color.FUCHSIA
@export var color_collision_point:Color = Color.GREEN


var camera_3d:Camera3D = null
var current_grid_point:Vector3 = Vector3.ZERO
var current_cell_size:float = 0

func _ready() -> void:
	if not build_interactor.testing:
		queue_free()

func _process(_delta):
	if not build_interactor.testing:
		return
	queue_redraw()

func _draw():
	if not build_interactor.testing:
		return
	camera_3d = get_viewport().get_camera_3d()
	current_grid_point = build_interactor.current_grid_point
	current_cell_size = build_interactor.current_cell_size
	draw_grid_center_point()
	draw_cell_border()
	draw_wall_points()
	draw_pillar_points()
	draw_collision_point()

func draw_collision_point():
	var hit_point:Vector2 = camera_3d.unproject_position(build_interactor.current_collision_point)
	draw_circle(hit_point, 2, color_collision_point)


func draw_grid_center_point():
	var cell_center:Vector2 = camera_3d.unproject_position(Grid.get_current_grid_point())
	draw_circle(cell_center, 3, color_center_point)

func draw_cell_border():
	var corner_base_1:Vector3 = Grid.ne
	var corner_base_2:Vector3 = Grid.se
	var corner_base_3:Vector3 = Grid.sw
	var corner_base_4:Vector3 = Grid.nw
	
	var base_points:Array[Vector3]=[
		corner_base_1,
		corner_base_2,
		corner_base_3, 
		corner_base_4
	]
	
	var i:int = 0
	for base_point in base_points:
		draw_circle(camera_3d.unproject_position(base_point), 3, color_border_lines)
		
		var line_start_point:Vector3 = base_points[i]
		var line_end_point:Vector3 = base_points[0]
		
		if i < base_points.size()-1:
			line_end_point = base_points[i+1]
		# Base lines...
		draw_line(camera_3d.unproject_position(line_start_point), camera_3d.unproject_position(line_end_point), color_border_lines, 1)
		# Top Lines
		draw_line(camera_3d.unproject_position(line_start_point+Vector3.UP * current_cell_size), camera_3d.unproject_position(line_end_point+Vector3.UP * current_cell_size), color_border_lines, 1)
		# Connecting base to top lines...
		draw_line(camera_3d.unproject_position(line_start_point), camera_3d.unproject_position(line_start_point+Vector3.UP * current_cell_size), color_border_lines, 1)
		i=i+1

func draw_wall_points():
	var distance_from_center:float = (current_cell_size/2)
	draw_circle(camera_3d.unproject_position(Grid.n), 3, color_wall_points)
	draw_circle(camera_3d.unproject_position(Grid.e), 3, color_wall_points)
	draw_circle(camera_3d.unproject_position(Grid.s), 3, color_wall_points)
	draw_circle(camera_3d.unproject_position(Grid.w), 3, color_wall_points)

func draw_pillar_points():
	var distance_from_center:float = (current_cell_size/2)
	var pillar_1 = Grid.ne
	var pillar_2 = Grid.se
	var pillar_3 = Grid.sw
	var pillar_4 = Grid.nw
	
	draw_circle(camera_3d.unproject_position(pillar_1), 3, color_pillar_points)
	draw_circle(camera_3d.unproject_position(pillar_2), 3, color_pillar_points)
	draw_circle(camera_3d.unproject_position(pillar_3), 3, color_pillar_points)
	draw_circle(camera_3d.unproject_position(pillar_4), 3, color_pillar_points)
