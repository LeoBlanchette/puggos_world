extends Control

class_name UIVector3

signal changed
@onready var spin_box_x: SpinBox = $Values/SpinBox_X
@onready var spin_box_y: SpinBox = $Values/SpinBox_Y
@onready var spin_box_z: SpinBox = $Values/SpinBox_Z

var value:Vector3 = Vector3.ZERO:
	get:
		return Vector3(spin_box_x.value, spin_box_y.value, spin_box_z.value)
	set(val):
		spin_box_x.value=val.x
		spin_box_y.value=val.y
		spin_box_z.value=val.z

func _ready() -> void:
	spin_box_x.value_changed.connect(_on_changed)
	spin_box_y.value_changed.connect(_on_changed)
	spin_box_z.value_changed.connect(_on_changed)
	

func _exit_tree() -> void:
	spin_box_x.value_changed.disconnect(_on_changed)
	spin_box_y.value_changed.disconnect(_on_changed)
	spin_box_z.value_changed.disconnect(_on_changed)
	
func _on_changed(value:float):
	changed.emit()
