extends Node2D

class_name EmoteDrawing

var show_point_locations:Array[Vector2] = []
@export var points_color:Color = Color.CHARTREUSE

func _draw():
	for point_location in show_point_locations:
		draw_circle(point_location, 2, points_color)		

func _process(_delta):
	queue_redraw()
