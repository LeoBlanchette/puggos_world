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

#region appearance
@export var avatar:Avatar 

## SLOT 0
var slot_0: int = -1:
	set(value):
		slot_0 = value
		equip_slot("slot_0", value)

## SLOT 1
var slot_1: int = -1:
	set(value):
		slot_1 = value
		equip_slot("slot_1", value)

## SLOT 2
var slot_2: int = -1:
	set(value):
		slot_2 = value
		equip_slot("slot_2", value)

## SLOT 3
var slot_3: int = -1:
	set(value):
		slot_3 = value
		equip_slot("slot_3", value)

## SLOT 4
var slot_4: int = -1:
	set(value):
		slot_4 = value
		equip_slot("slot_4", value)

## SLOT 5
var slot_5: int = -1:
	set(value):
		slot_5 = value
		equip_slot("slot_5", value)

## SLOT 6
var slot_6: int = -1:
	set(value):
		slot_6 = value
		equip_slot("slot_6", value)

## SLOT 7
var slot_7: int = -1:
	set(value):
		slot_7 = value
		equip_slot("slot_7", value)

## SLOT 8
var slot_8: int = -1:
	set(value):
		slot_8 = value
		equip_slot("slot_8", value)

## SLOT 9
var slot_9: int = -1:
	set(value):
		slot_9 = value
		equip_slot("slot_9", value)

## SLOT 10
var slot_10: int = -1:
	set(value):
		slot_10 = value
		equip_slot("slot_10", value)

## SLOT 11
var slot_11: int = -1:
	set(value):
		slot_11 = value
		equip_slot("slot_11", value)

## SLOT 12
var slot_12: int = -1:
	set(value):
		slot_12 = value
		equip_slot("slot_12", value)

## SLOT 13
var slot_13: int = -1:
	set(value):
		slot_13 = value
		equip_slot("slot_13", value)

## SLOT 14
var slot_14: int = -1:
	set(value):
		slot_14 = value
		equip_slot("slot_14", value)

## SLOT 15
var slot_15: int = -1:
	set(value):
		slot_15 = value
		equip_slot("slot_15", value)

## SLOT 16
var slot_16: int = -1:
	set(value):
		slot_16 = value
		equip_slot("slot_16", value)

## SLOT 17
var slot_17: int = -1:
	set(value):
		slot_17 = value
		equip_slot("slot_17", value)

## SLOT 18
var slot_18: int = -1:
	set(value):
		slot_18 = value
		equip_slot("slot_18", value)

## SLOT 19
var slot_19: int = -1:
	set(value):
		slot_19 = value
		equip_slot("slot_19", value)

## SLOT 20
var slot_20: int = -1:
	set(value):
		slot_20 = value
		equip_slot("slot_20", value)

## SLOT 21
var slot_21: int = -1:
	set(value):
		slot_21 = value
		equip_slot("slot_21", value)

## SLOT 22
var slot_22: int = -1:
	set(value):
		slot_22 = value
		equip_slot("slot_22", value)

## SLOT 23
var slot_23: int = -1:
	set(value):
		slot_23 = value
		equip_slot("slot_23", value)

## SLOT 24
var slot_24: int = -1:
	set(value):
		slot_24 = value
		equip_slot("slot_24", value)

## SLOT 25
var slot_25: int = -1:
	set(value):
		slot_25 = value
		equip_slot("slot_25", value)

## SLOT 26
var slot_26: int = -1:
	set(value):
		slot_26 = value
		equip_slot("slot_26", value)

## SLOT 27
var slot_27: int = -1:
	set(value):
		slot_27 = value
		equip_slot("slot_27", value)

## SLOT 28
var slot_28: int = -1:
	set(value):
		slot_28 = value
		equip_slot("slot_28", value)

## SLOT 29
var slot_29: int = -1:
	set(value):
		slot_29 = value
		equip_slot("slot_29", value)

## SLOT 30
var slot_30: int = -1:
	set(value):
		slot_30 = value
		equip_slot("slot_30", value)

## SLOT 31
var slot_31: int = -1:
	set(value):
		slot_31 = value
		equip_slot("slot_31", value)

## SLOT 32
var slot_32: int = -1:
	set(value):
		slot_32 = value
		equip_slot("slot_32", value)

## SLOT 33
var slot_33: int = -1:
	set(value):
		slot_33 = value
		equip_slot("slot_33", value)

## SLOT 34
var slot_34: int = -1:
	set(value):
		slot_34 = value
		equip_slot("slot_34", value)

## SLOT 35
var slot_35: int = -1:
	set(value):
		slot_35 = value
		equip_slot("slot_35", value)

## SLOT 36
var slot_36: int = -1:
	set(value):
		slot_36 = value
		equip_slot("slot_36", value)

## SLOT 37
var slot_37: int = -1:
	set(value):
		slot_37 = value
		equip_slot("slot_37", value)

## SLOT 38
var slot_38: int = -1:
	set(value):
		slot_38 = value
		equip_slot("slot_38", value)

## SLOT 39
var slot_39: int = -1:
	set(value):
		slot_39 = value
		equip_slot("slot_39", value)

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

## The main entry point for equipping object to a slot.
func equip(id:int):
	if ObjectIndex.object_index.has_object("items", id):
		var ob:Node3D = ObjectIndex.object_index.get_object("items", id)
		if not ob.has_meta("equippable_slot"):
			print("This object cannot be assigned to a slot. Either it was not assigned in SDK, or the object is not slot compatible.")
			return
		var slot_number:int = ob.get_meta("equippable_slot", 0)
		if slot_number == 0:
			print("Slot number was improperly assigned. Cannot use.")
		var slot:String = "slot_%s"%str(slot_number)
		
		## Set the given variable by string 
		set(slot, id)
		
## The avatar controller function for equipping object to a slot. It is called by
## a slot_<i> variable being set.
func equip_slot(slot:String, id:int):
	if ObjectIndex.object_index.has_object("items", id):
		var ob:Node3D = ObjectIndex.object_index.get_object("items", id)
		if not ob.has_meta("equippable_slot"):
			print("This object cannot be assigned to a slot. Either it was not assigned in SDK, or the object is not slot compatible.")
			return
		var slot_number:int = ob.get_meta("equippable_slot", 0)
		if slot_number == 0:
			print("Slot number was improperly assigned. Cannot use.")
		
		avatar.equip(slot, ob.scene_file_path)

#func _on_controller_emerged():
	#camera.environment = null
#
#
#func _on_controller_subemerged():
	#camera.environment = underwater_env
