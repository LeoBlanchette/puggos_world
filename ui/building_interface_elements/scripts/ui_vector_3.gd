extends Control

class_name UIVector3

enum CurrentSpinBox{
	NONE,
	X,
	Y,
	Z
}

var current_spin_box:CurrentSpinBox = CurrentSpinBox.NONE

signal changed
@export var label:Label
@export var spin_box_x: LineEdit 
@export var spin_box_y: LineEdit
@export var spin_box_z: LineEdit 
@export var drag_force:float

@export var actual_value:Vector3

var spin_box_allowed:bool = false
var is_attempting_drag:bool = false
var starting_drag_point:Vector2 = Vector2.ZERO
var current_drag_point:Vector2 = Vector2.ZERO
var starting_spinbox_value:float = 0

var value:Vector3 = Vector3.ZERO:
	get:
		return actual_value
	set(val):
		_set_values(val)

func _gui_input(event: InputEvent) -> void:
	if not spin_box_allowed && not is_attempting_drag:
		return
	if event.is_action_released("left_mouse_button"):
		reset_spin_op()
		is_attempting_drag = false
	if event.is_action_pressed("left_mouse_button"):
		is_attempting_drag = true
	if not is_attempting_drag:
		return
	do_spinbox_op()


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


#region Spinbox Ops
func do_spinbox_op():
	if starting_drag_point == Vector2.ZERO:
		starting_drag_point = get_viewport().get_mouse_position()
	current_drag_point = get_viewport().get_mouse_position()
	var distance:float = starting_drag_point.distance_to(current_drag_point)
	var positive:bool = true
	if current_drag_point.x < starting_drag_point.x:
		positive = false
	if current_spin_box == CurrentSpinBox.NONE:
		return
	var current_line_edit:LineEdit
	match current_spin_box:
		CurrentSpinBox.X:
			current_line_edit = spin_box_x
			if starting_spinbox_value == 0:
				starting_spinbox_value = actual_value.x
		CurrentSpinBox.Y:
			current_line_edit = spin_box_y
			if starting_spinbox_value == 0:
				starting_spinbox_value = actual_value.y
		CurrentSpinBox.Z:
			current_line_edit = spin_box_z
			if starting_spinbox_value == 0:
				starting_spinbox_value = actual_value.z
	
	if positive:
		current_line_edit.value = starting_spinbox_value + (distance * drag_force)
	else:
		current_line_edit.value = starting_spinbox_value - (distance * drag_force)
	current_line_edit.text = str(current_line_edit.value)

	match current_spin_box:
		CurrentSpinBox.X:
			actual_value.x = spin_box_x.value
		CurrentSpinBox.Y:
			actual_value.y = spin_box_y.value
		CurrentSpinBox.Z:
			actual_value.z = spin_box_z.value
	changed.emit()
	
func reset_spin_op():
	starting_drag_point = Vector2.ZERO
	current_drag_point = Vector2.ZERO
	current_spin_box = CurrentSpinBox.NONE
	starting_spinbox_value = 0
	is_attempting_drag = false

func _on_label_x_mouse_entered() -> void:
	if is_attempting_drag:
		return
	current_spin_box = CurrentSpinBox.X
	spin_box_allowed = true

func _on_label_x_mouse_exited() -> void:
	spin_box_allowed = false

func _on_label_y_mouse_entered() -> void:
	if is_attempting_drag:
		return
	current_spin_box = CurrentSpinBox.Y
	spin_box_allowed = true

func _on_label_y_mouse_exited() -> void:
	spin_box_allowed = false

func _on_label_z_mouse_entered() -> void:
	if is_attempting_drag:
		return
	current_spin_box = CurrentSpinBox.Z
	spin_box_allowed = true

func _on_label_z_mouse_exited() -> void:
	spin_box_allowed = false
#endregion 
