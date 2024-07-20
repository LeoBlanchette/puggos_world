extends Node
## Creates a target setup which simplifies calculations and does other useful 
## operations that involve targeting. Build as needed.
class_name Targeting

var target:Node3D
var origin:Node3D
var distance:float

func _init(_target:Node3D, _origin:Node3D) -> void:
	target = _target
	origin = _origin
	distance = origin.global_position.distance_to(target.global_position)
