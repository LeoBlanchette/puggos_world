extends Control

class_name UIVector3

signal changed
@export var label:Label
@export var spin_box_x: LineEdit 
@export var spin_box_y: LineEdit
@export var spin_box_z: LineEdit 

@export var actual_value:Vector3

var value:Vector3 = Vector3.ZERO:
	get:
		return actual_value
	set(val):
		_set_values(val)

func _ready() -> void:
	_set_values(Vector3.ZERO)
	spin_box_x.text_submitted.connect(_on_changed_x)
	spin_box_y.text_submitted.connect(_on_changed_y)
	spin_box_z.text_submitted.connect(_on_changed_z)
	
func _set_values(vector:Vector3):
	actual_value = vector
	spin_box_x.text = str(snapped(vector.x, 0.0001))
	spin_box_y.text = str(snapped(vector.y, 0.0001))
	spin_box_z.text = str(snapped(vector.z, 0.0001))

func _exit_tree() -> void:
	spin_box_x.text_submitted.disconnect(_on_changed_x)
	spin_box_y.text_submitted.disconnect(_on_changed_y)
	spin_box_z.text_submitted.disconnect(_on_changed_z)
	
func _on_changed_x(val:String):
	actual_value.x = float(val)
	changed.emit()
	
func _on_changed_y(val:String):
	actual_value.y = float(val)
	changed.emit()
	
func _on_changed_z(val:String):
	actual_value.z = float(val)
	changed.emit()
