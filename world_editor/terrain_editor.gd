extends Node3D

class_name  TerrainEditor


func initiate():
	WorldEditor.instance.spawn_object("terrains", 1, Vector3.ZERO, Vector3.ZERO)


func _input(event: InputEvent) -> void:
	pass
