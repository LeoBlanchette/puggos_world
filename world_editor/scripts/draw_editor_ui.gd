extends Control

class_name DrawEditorUI

var stretch_line:Array[Vector2] = []:
	set(value):
		stretch_line = value
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
	stretch_line = []
	queue_redraw()

func _draw() -> void:
	if not stretch_line.is_empty():
		do_stretch_line()

func do_stretch_line():
	if stretch_line.is_empty():
		return
	draw_line(stretch_line[0], stretch_line[1], Color.GREEN, 1.0)
