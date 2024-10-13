extends Node3D

class_name ClimbSensor

@onready var climb_target_sensor: RayCast3D = $ClimbTargetSensor

## Is foot block?
@onready var sensor_1: RayCast3D = $Sensor_1

## Is Step-up area blocked?
@onready var sensor_2: RayCast3D = $Sensor_2

## Is climb-up area blocked. 
@onready var sensor_3: RayCast3D = $Sensor_3

var block_jump:bool:
	get():
		if is_step_up_available:
			return true
		if is_climb_up_available:
			return true
		return false

var is_step_up_available:bool = false

var is_climb_up_available:bool = false

func _physics_process(delta: float) -> void:
	if not is_forward_movement_blocked():
		is_step_up_available = false
		is_climb_up_available = false
		return
	update_climb_availability()


func is_forward_movement_blocked():
	if sensor_1.is_colliding():
		return true
	if sensor_2.is_colliding():
		return true
	if sensor_3.is_colliding():
		return true
	return false

func update_climb_availability():
	if sensor_1.is_colliding() && not sensor_2.is_colliding() && not sensor_3.is_colliding():
		is_step_up_available = true
		is_climb_up_available = false
		return
	if  sensor_2.is_colliding() && not sensor_3.is_colliding():
		is_step_up_available = false
		is_climb_up_available = true
		return

## Returns the destination point of a potential climb operation.
## Returns Vector3.ZERO if no target.
func get_climb_target()->Vector3:
	if climb_target_sensor.is_colliding():
		return climb_target_sensor.get_collision_point()
	return Vector3.ZERO
