extends Node3D

func _ready() -> void:
	position = Vector3.ZERO
	rotation = Vector3.ZERO

	var modular_element:Node = get_parent()
	
	var build_object_validator: BuildObjectValidator = BuildObjectValidator.new(modular_element)
	
	if build_object_validator.get_current_object_anchor_type() == BuildObjectValidator.AnchorType.NONE:
		return
	
	var anchor_set_path:String = build_object_validator.get_anchor_set_path()
	
	if anchor_set_path.is_empty():
		return	
	
	var anchor_set_object:Resource = load(anchor_set_path)
	
	
	var anchors_foundation:Marker3D = anchor_set_object.instantiate()
	self.add_child(anchors_foundation, true)
	anchors_foundation.position = Vector3.ZERO
	anchors_foundation.rotation = Vector3.ZERO
