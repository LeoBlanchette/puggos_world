extends Node

class_name BuildObjectValidator

var current_object:Node = null
var target_object:Node = null
enum AnchorType {NONE, FOUNDATION, PILLAR, WALL, FLOOR}

const FOUNDATION_ANCHOR = "res://nodes/build_kits/anchors/anchors_foundation.tscn"
const FOUNDATION_FLOOR = "res://nodes/build_kits/anchors/anchors_floor.tscn"

func _init(_current_object:Node, _target_object:Node = null) -> void:
	self.current_object = _current_object
	self.target_object = _target_object

func get_current_object_anchor_type()->AnchorType:
	return get_anchor_type(current_object)

func get_target_object_anchor_type()->AnchorType:
	return get_anchor_type(target_object);

func get_anchor_type(ob)->AnchorType:
	if ob == null:
		return AnchorType.NONE
	var anchor_type_string = ob.get_meta("anchor_type", "none")
	match anchor_type_string:
		"none":
			return AnchorType.NONE
		"wall":
			return AnchorType.WALL
		"pillar":
			return AnchorType.PILLAR
		"floor":
			return AnchorType.FLOOR
		"foundation":
			return AnchorType.FOUNDATION
	
	return AnchorType.NONE

func is_compatible_target()->bool:
	var current_object_anchor_type = get_anchor_type(current_object)
	var target_object_anchor_type = get_anchor_type(target_object)
	
	if current_object_anchor_type == target_object_anchor_type:
		return true	
	return false

## This is for getting the appropriate anchor set (such as the foundation, with snaps for walls, pillars, etc)
func get_anchor_set_path()->String:
	var anchor_type:AnchorType = get_current_object_anchor_type()
	
	match anchor_type:		
		AnchorType.FOUNDATION:
			return FOUNDATION_ANCHOR
		AnchorType.FLOOR:
			return FOUNDATION_FLOOR
		
	return ""

## When the raycast is being done, we have the objects on different layers 
## so that the various height colliders do not block player's goal, such as
## when attempting to place an upper floor, but is blocked by a wall collider.
func get_build_detection_collision_layers() -> Array:
	var achor_type:AnchorType = get_current_object_anchor_type()
	
	#32 is foundation
	#31 is wall
	#30 is floor
	
	match achor_type:
		AnchorType.FOUNDATION:
			return [2, 32]
		AnchorType.PILLAR:
			return [2, 31] #pillar is considered a wall level element.
		AnchorType.WALL:
			return [2, 31]
		AnchorType.FLOOR:
			return [2, 30]
		_:
			return [2, 32,31,30]	
