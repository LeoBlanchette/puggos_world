extends Control

class_name DrawEditorUI

var current_axis:EditorGizmo.Axis = EditorGizmo.Axis.X

var guide_lines:Array[Vector2] = []:
	set(value):
		guide_lines = value
		queue_redraw()
var guide_lines_rotation:Array[Vector2] = []:
	set(value):
		guide_lines_rotation = value
		queue_redraw()
var arbitrary_line:Array[Vector2] = []:
	set(value):
		arbitrary_line = value
		queue_redraw()

var point_marker:Array[Vector2] = []:
	set(value):
		point_marker = value
		queue_redraw()

static var instance:DrawEditorUI = null

func _init() -> void:
	if instance == null:
		instance = self
	else:
		queue_free()

func _exit_tree() -> void:
	if instance == self:
		instance = null

func clear():
	guide_lines = []
	guide_lines_rotation = []

func _draw() -> void:
	if not guide_lines.is_empty():
		do_guide_lines()		
	if not guide_lines_rotation.is_empty():
		do_guide_lines_rotation()
	if not arbitrary_line.is_empty():
		do_arbitrary_line()
	if not point_marker.is_empty():
		do_point_marker()
		
func do_arbitrary_line():
	if arbitrary_line.is_empty():
		return
	draw_line(arbitrary_line[0], arbitrary_line[1], Color.RED, 1.0)
	
func do_guide_lines():
	if guide_lines.is_empty():
		return
	
	var color:Color
	
	match current_axis:
		EditorGizmo.Axis.X:
			color = Color.RED
		EditorGizmo.Axis.Y:
			color = Color.LIME_GREEN
		EditorGizmo.Axis.Z:
			color = Color.DODGER_BLUE

	draw_line(guide_lines[0], guide_lines[1], Color.WHITE, 1.0) 
	draw_line(guide_lines[1], guide_lines[2], color, 1.0) #in line with axis
	draw_line(guide_lines[2], guide_lines[0], Color.GRAY, 1.0)
	
	draw_circle(guide_lines[0], 2, Color.WHITE)
	draw_circle(guide_lines[1], 2, Color.WHITE)
	draw_circle(guide_lines[2], 2, Color.WHITE)

func do_guide_lines_rotation():
	if guide_lines_rotation.is_empty():
		return
	var color:Color
	match current_axis:
		EditorGizmo.Axis.X:
			color = Color.RED
		EditorGizmo.Axis.Y:
			color = Color.LIME_GREEN
		EditorGizmo.Axis.Z:
			color = Color.DODGER_BLUE
	var rotation_start_mark:Vector2 = guide_lines_rotation[0]
	var rotation_end_mark:Vector2 = guide_lines_rotation[1]
	var origin_mark:Vector2 = guide_lines_rotation[2]
	draw_line(origin_mark, rotation_start_mark, Color.WHITE, 1.0) 
	draw_line(origin_mark, rotation_end_mark, color, 1.0) #in line with axis

	draw_circle(rotation_start_mark, 2, Color.WHITE)
	draw_circle(rotation_end_mark, 2, Color.WHITE)
	draw_circle(origin_mark, 2, Color.WHITE)


func do_point_marker():
	for point in point_marker:
		draw_circle(point, 3, Color.RED)
