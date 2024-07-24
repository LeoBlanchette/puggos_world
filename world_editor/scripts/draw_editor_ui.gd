extends Control

class_name DrawEditorUI

var guide_lines:Array[Vector2] = []:
	set(value):
		guide_lines = value
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

func _draw() -> void:
	if not guide_lines.is_empty():
		do_guide_lines()		
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
	draw_line(guide_lines[0], guide_lines[1], Color.LIGHT_GREEN, 1.0)
	draw_line(guide_lines[1], guide_lines[2], Color.SKY_BLUE, 1.0)
	draw_line(guide_lines[2], guide_lines[0], Color.SKY_BLUE, 1.0)
	
func do_point_marker():
	for point in point_marker:
		draw_circle(point, 3, Color.RED)
