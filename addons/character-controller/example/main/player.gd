extends FPSController3D
class_name Player

## Example script that extends [CharacterController3D] through 
## [FPSController3D].
## 
## This is just an example, and should be used as a basis for creating your 
## own version using the controller's [b]move()[/b] function.
## 
## This player contains the inputs that will be used in the function 
## [b]move()[/b] in [b]_physics_process()[/b].
## The input process only happens when mouse is in capture mode.
## This script also adds submerged and emerged signals to change the 
## [Environment] when we are in the water.

#region deactivate if not player

@export var camera_3d:Camera3D

#endregion

@export var multiplayer_synchronizer:MultiplayerSynchronizer

@export var input_back_action_name := "move_backward"
@export var input_forward_action_name := "move_forward"
@export var input_left_action_name := "move_left"
@export var input_right_action_name := "move_right"
@export var input_sprint_action_name := "move_sprint"
@export var input_jump_action_name := "move_jump"
@export var input_crouch_action_name := "move_crouch"
@export var input_fly_mode_action_name := "move_fly_mode"

@export var underwater_env: Environment

@export var builder_node: Node
@export var spawner_node: Node3D

var activated:bool = false

var peer_id:int = 0

func _ready():		
	if peer_id == multiplayer.get_unique_id():
		camera_3d.current = true
	setup()	
	$Register_Player.activate()	


func _physics_process(delta):
	multiplayer_synchronizer.position = position
	multiplayer_synchronizer.rotation = rotation
	if not multiplayer_synchronizer.is_multiplayer_authority():
		return
	var is_valid_input := Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	
	if is_valid_input:
		if Input.is_action_just_pressed(input_fly_mode_action_name):
			fly_ability.set_active(not fly_ability.is_actived())
		var input_axis = Input.get_vector(input_left_action_name, input_right_action_name, input_back_action_name, input_forward_action_name)
		var input_jump = Input.is_action_just_pressed(input_jump_action_name)
		var input_crouch = Input.is_action_pressed(input_crouch_action_name)
		var input_sprint = Input.is_action_pressed(input_sprint_action_name)
		var input_swim_down = Input.is_action_pressed(input_crouch_action_name)
		var input_swim_up = Input.is_action_pressed(input_jump_action_name)
		move(delta, input_axis, input_jump, input_crouch, input_sprint, input_swim_down, input_swim_up)
	else:
		# NOTE: It is important to always call move() even if we have no inputs 
		## to process, as we still need to calculate gravity and collisions.
		move(delta)

func _input(event: InputEvent) -> void:
	if not multiplayer_synchronizer.is_multiplayer_authority():
		return
	# Mouse look (only if the mouse is captured).
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_head(event.relative)

func enter_placement_mode(object_category:String, object_id:int):
	builder_node.enter_placement_mode(object_category, object_id)


func get_spawner_node()->Node3D:
	return spawner_node

func get_peer_id()->int:
	return peer_id

func get_camera()->Camera3D:
	return camera_3d

#func _on_controller_emerged():
	#camera.environment = null
#
#
#func _on_controller_subemerged():
	#camera.environment = underwater_env
