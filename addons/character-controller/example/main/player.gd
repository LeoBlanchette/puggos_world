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

#region action signals
signal primary_action_pressed
signal secondary_action_pressed
signal primary_action_alt_pressed
signal seconary_action_alt_pressed
signal do_action_basic_interact_pressed
#endregion

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

#region avatar appearance
@export var avatar:Avatar 


## SLOT 0
@export var slot_0: int = -1:
	set(value):
		slot_0 = value
		equip_slot("slot_0", value)

## SLOT 1
@export var slot_1: int = -1:
	set(value):
		slot_1 = value
		equip_slot("slot_1", value)

## SLOT 2
@export var slot_2: int = -1:
	set(value):
		slot_2 = value
		equip_slot("slot_2", value)

## SLOT 3
@export var slot_3: int = -1:
	set(value):
		slot_3 = value
		equip_slot("slot_3", value)

## SLOT 4
@export var slot_4: int = -1:
	set(value):
		slot_4 = value
		equip_slot("slot_4", value)

## SLOT 5
@export var slot_5: int = -1:
	set(value):
		slot_5 = value
		equip_slot("slot_5", value)

## SLOT 6
@export var slot_6: int = -1:
	set(value):
		slot_6 = value
		equip_slot("slot_6", value)

## SLOT 7
@export var slot_7: int = -1:
	set(value):
		slot_7 = value
		equip_slot("slot_7", value)

## SLOT 8
@export var slot_8: int = -1:
	set(value):
		slot_8 = value
		equip_slot("slot_8", value)

## SLOT 9
@export var slot_9: int = -1:
	set(value):
		slot_9 = value
		equip_slot("slot_9", value)

## SLOT 10
@export var slot_10: int = -1:
	set(value):
		slot_10 = value
		equip_slot("slot_10", value)

## SLOT 11
@export var slot_11: int = -1:
	set(value):
		slot_11 = value
		equip_slot("slot_11", value)

## SLOT 12
@export var slot_12: int = -1:
	set(value):
		slot_12 = value
		equip_slot("slot_12", value)

## SLOT 13
@export var slot_13: int = -1:
	set(value):
		slot_13 = value
		equip_slot("slot_13", value)

## SLOT 14
@export var slot_14: int = -1:
	set(value):
		slot_14 = value
		equip_slot("slot_14", value)

## SLOT 15
@export var slot_15: int = -1:
	set(value):
		slot_15 = value
		equip_slot("slot_15", value)

## SLOT 16
@export var slot_16: int = -1:
	set(value):
		slot_16 = value
		equip_slot("slot_16", value)

## SLOT 17
@export var slot_17: int = -1:
	set(value):
		slot_17 = value
		equip_slot("slot_17", value)

## SLOT 18
@export var slot_18: int = -1:
	set(value):
		slot_18 = value
		equip_slot("slot_18", value)

## SLOT 19
@export var slot_19: int = -1:
	set(value):
		slot_19 = value
		equip_slot("slot_19", value)

## SLOT 20
@export var slot_20: int = -1:
	set(value):
		slot_20 = value
		equip_slot("slot_20", value)

## SLOT 21
@export var slot_21: int = -1:
	set(value):
		slot_21 = value
		equip_slot("slot_21", value)

## SLOT 22
@export var slot_22: int = -1:
	set(value):
		slot_22 = value
		equip_slot("slot_22", value)

## SLOT 23
@export var slot_23: int = -1:
	set(value):
		slot_23 = value
		equip_slot("slot_23", value)

## SLOT 24
@export var slot_24: int = -1:
	set(value):
		slot_24 = value
		equip_slot("slot_24", value)

## SLOT 25
@export var slot_25: int = -1:
	set(value):
		slot_25 = value
		equip_slot("slot_25", value)

## SLOT 26
@export var slot_26: int = -1:
	set(value):
		slot_26 = value
		equip_slot("slot_26", value)

## SLOT 27
@export var slot_27: int = -1:
	set(value):
		slot_27 = value
		equip_slot("slot_27", value)

## SLOT 28
@export var slot_28: int = -1:
	set(value):
		slot_28 = value
		equip_slot("slot_28", value)

## SLOT 29
@export var slot_29: int = -1:
	set(value):
		slot_29 = value
		equip_slot("slot_29", value)

## SLOT 30
@export var slot_30: int = -1:
	set(value):
		slot_30 = value
		equip_slot("slot_30", value)

## SLOT 31
@export var slot_31: int = -1:
	set(value):
		slot_31 = value
		equip_slot("slot_31", value)

## SLOT 32
@export var slot_32: int = -1:
	set(value):
		slot_32 = value
		equip_slot("slot_32", value)

## SLOT 33
@export var slot_33: int = -1:
	set(value):
		slot_33 = value
		equip_slot("slot_33", value)

## SLOT 34
@export var slot_34: int = -1:
	set(value):
		slot_34 = value
		equip_slot("slot_34", value)

## SLOT 35
@export var slot_35: int = -1:
	set(value):
		slot_35 = value
		equip_slot("slot_35", value)

## SLOT 36
@export var slot_36: int = -1:
	set(value):
		slot_36 = value
		equip_slot("slot_36", value)

## SLOT 37
@export var slot_37: int = -1:
	set(value):
		slot_37 = value
		equip_slot("slot_37", value)

## SLOT 38
@export var slot_38: int = -1:
	set(value):
		slot_38 = value
		equip_slot("slot_38", value)

## SLOT 39
@export var slot_39: int = -1:
	set(value):
		slot_39 = value
		equip_slot("slot_39", value)
#endregion

#region avatar animation
var input_axis:Vector2 = Vector2.ZERO
		
var input_jump:bool = false
		
var input_crouch:bool = false
		
var input_sprint:bool = false
		
var input_swim_down:bool = false
		
var input_swim_up:bool = false

@export var blend_position:Vector2 
@export var is_crouched:bool = false
@export var is_combat_mode:bool = false
@export var is_moving:bool = false
@export var is_running:bool = false
@export var affected_body_region:String = "NONE"
#endregion

func _ready():		
	if peer_id == multiplayer.get_unique_id():
		camera_3d.current = true
	setup()	
	$Register_Player.activate()
	equip(28) # DEFAULT skin.

func _physics_process(delta):
	update_avatar_animation_global()
	multiplayer_synchronizer.position = position
	multiplayer_synchronizer.rotation = rotation
	if not multiplayer_synchronizer.is_multiplayer_authority():
		return
	update_avatar_animation_local()
	var is_valid_input := Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	
	if is_valid_input:
		if Input.is_action_just_pressed(input_fly_mode_action_name):
			fly_ability.set_active(not fly_ability.is_actived())
		input_axis = Input.get_vector(input_left_action_name, input_right_action_name, input_back_action_name, input_forward_action_name)
		input_jump = Input.is_action_just_pressed(input_jump_action_name)
		input_crouch = Input.is_action_pressed(input_crouch_action_name)
		input_sprint = Input.is_action_pressed(input_sprint_action_name)
		input_swim_down = Input.is_action_pressed(input_crouch_action_name)
		input_swim_up = Input.is_action_pressed(input_jump_action_name)
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
		
	# Main Actions
	if event is InputEventMouseButton:
		if event.is_action_pressed("left_mouse_button"):
			do_action_primary()
		if event.is_action_pressed("right_mouse_button"):
			do_action_secondary()
		if event.is_action_pressed("left_mouse_button_alt"):
			do_action_primary_alt()
		if event.is_action_pressed("right_mouse_button_alt"):
			do_action_secondary_alt()

	if event is InputEventKey:
		if event.is_action_pressed("basic_interact"):
			do_action_basic_interact()
			
func update_avatar_animation_local():
	blend_position = input_axis
	is_crouched = is_crouching()
	is_running = is_sprinting()
	if blend_position != Vector2.ZERO:
		is_moving = true
	else:
		is_moving = false

func update_avatar_animation_global():
	avatar.is_crouching = is_crouched
	avatar.is_combat_mode = is_combat_mode
	avatar.is_running = is_running
	avatar.movement = blend_position

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
	if avatar == null:
		return # not ready yet
	if id == -1: # This means to clear the slot:
		avatar.equip(slot, "")
		return
	if ObjectIndex.object_index.has_object("items", id):
		var ob:Node3D = ObjectIndex.object_index.get_object("items", id)
		if not ob.has_meta("equippable_slot"):
			print("This object cannot be assigned to a slot. Either it was not assigned in SDK, or the object is not slot compatible.")
			return
		var slot_number:int = ob.get_meta("equippable_slot", 0)
		if slot_number == 0:
			print("Slot number was improperly assigned. Cannot use.")
		
		var path = ob.scene_file_path
	
		if slot_number in [1, 2, 3]: # if these slots, its skin layers. Change path...
			path  = path.replace("item.tscn", "texture.png")

		avatar.equip(slot, path)

func unequip(slot:String):
	set(slot, -1)

func do_action_primary():
	print("do_action_primary()")
	primary_action_pressed.emit()

func do_action_secondary():
	print("do_action_secondary()")
	secondary_action_pressed.emit()

func do_action_primary_alt():
	print("do_action_primary_alt()")
	primary_action_alt_pressed.emit()
	
func do_action_secondary_alt():
	print("do_action_secondary_alt()")
	seconary_action_alt_pressed.emit()

func do_action_basic_interact():
	print("do_action_basic_interact()")
	do_action_basic_interact_pressed.emit()

#func _on_controller_emerged():
	#camera.environment = null
#
#
#func _on_controller_subemerged():
	#camera.environment = underwater_env
