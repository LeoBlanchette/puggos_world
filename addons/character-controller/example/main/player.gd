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
signal primary_action_pressed(on:bool)
signal secondary_action_pressed(on:bool)
signal primary_action_alt_pressed(on:bool)
signal seconary_action_alt_pressed(on:bool)
signal do_action_basic_interact_pressed(on:bool)
signal is_short_idle_changed(value)
signal is_long_idle_changed(value)
signal player_stopped
signal player_moved
signal personality_id_changed(value:int)
signal do_action_step_up
signal do_action_climb_up
signal climb_up_started(process_time:float)
signal climb_up_stopped
signal step_up_started(process_time:float)
signal step_up_stopped
#endregion

#region emote signals
signal emote_changed(value:int)
#endregion 

#region deactivate if not player
@export var camera_3d:Camera3D
#endregion

@export var multiplayer_synchronizer:MultiplayerSynchronizer

@export var underwater_env: Environment

@export var build_interactor: BuildInteractor 

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

#region emotes
@export var emote:int = -1:
	set(value):
		emote = value
		emote_changed.emit(value)
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
@export var has_player_stopped:bool = true

## Used by signal system to prevent double-fires of the signal upon player moving.
var player_moved_signaled:bool = false

## Used by signal system to prevent double-fires of the signal upon player stopped.
var player_stopped_signaled:bool = false

@export var personality_id:int = 55:
	set(value):
		personality_id = value
		personality_id_changed.emit(personality_id)

## The long-idle animation (Personality)
@export var long_idle_time:float = 45.0
@export var is_long_idle:bool = false:
	set(value): 
		if value != is_long_idle:
			is_long_idle_changed.emit(value)
		is_long_idle = value

## The short-idle animation. Engages immediately when idle.
@export var short_idle_time:float = 0.1
@export var is_short_idle:bool = false:
	set(value): 
		if value != is_short_idle:
			is_short_idle_changed.emit(value)
		is_short_idle = value

var last_position:Vector3 = Vector3.ZERO
var time_idling:float = 0.0

@export var display_mode = false:
	set(value):
		display_mode = value
		if value == true:
			enter_display_mode()
			
@onready var view_switch: Node = $"View Switch"
@onready var climb_sensor: ClimbSensor = $ClimbSensor

@export var projected_view_marker:Vector3 = Vector3.ZERO
#endregion

#region rate limiting and timing
## Initially used 
var object_uptime:float = 0

## Time between action clicks allowed
var action_rate_limit_time:float = 0.25

## Whether we may accept input for actions
var is_actions_rate_limited:bool = false

var enforce_rate_limit:bool = false

@export var rate_limit_timer:Timer = null
#endregion 

#region climb process

var is_climbing_up:bool = false
var is_stepping_up:bool = false
var climb_up_time:float = 0
var step_up_time:float = 0
var climb_up_time_elapsed:float = 0
var step_up_time_elapsed:float = 0
#endregion 

func _ready():
	if peer_id == multiplayer.get_unique_id():
		camera_3d.current = true
	setup()	
	$Register_Player.activate()
	equip(28) # DEFAULT skin.
	last_position = position
	setup_animation_library()
	player_moved.connect(acknowledge_player_moved_signal)
	player_stopped.connect(acknowledge_player_stopped_signal)
	PlayerInput.head_motion_relative_changed.connect(rotate_head)
	
	step_up_started.connect(do_process_step_up)
	climb_up_started.connect(do_process_climb_up)	
	step_up_stopped.connect(stop_process_step_up)
	climb_up_stopped.connect(stop_process_climb_up)	
	
	## The remaining is player controlled only. 
	if not is_multiplayer_authority():
		return
	
	# Actions Engaged
	PlayerInput.primary_action_pressed.connect(trigger_action_primary)
	PlayerInput.secondary_action_pressed.connect(trigger_action_secondary)
	PlayerInput.primary_action_alt_pressed.connect(trigger_action_primary_alt)
	PlayerInput.secondary_action_alt_pressed.connect(trigger_action_secondary_alt)
	PlayerInput.action_basic_interact_pressed.connect(trigger_action_basic_interact)
	
	# Actions Released
	PlayerInput.primary_action_released.connect(end_action_primary)
	PlayerInput.secondary_action_released.connect(end_action_secondary)
	PlayerInput.primary_action_alt_released.connect(end_action_primary_alt)
	PlayerInput.secondary_action_alt_released.connect(end_action_secondary_alt)
	PlayerInput.action_basic_interact_released.connect(end_action_basic_interact)

func _enter_tree() -> void:
	if not is_multiplayer_authority():
		return
	await ready
	PlayerInput.register_character_object(self)

func _process(delta: float) -> void:
	object_uptime += delta
	if display_mode:
		return
	update_avatar_animation_global()
	multiplayer_synchronizer.position = position
	multiplayer_synchronizer.rotation = rotation
	if not multiplayer_synchronizer.is_multiplayer_authority():
		return
	if not is_multiplayer_authority():
		return
	update_view_marker()
	update_avatar_animation_local()
	
	if is_climbing_up:
		return	
	if is_stepping_up:
		return

	if PlayerInput.is_valid_player_input:
		if PlayerInput.fly_mode_toggled:
			fly_ability.set_active(not fly_ability.is_actived())
		input_axis = PlayerInput.input_axis
		input_jump = PlayerInput.input_jump
		input_crouch = PlayerInput.input_crouch
		input_sprint = PlayerInput.input_sprint
		input_swim_down = PlayerInput.input_swim_down
		input_swim_up = PlayerInput.input_swim_up
		if input_jump && climb_sensor.block_jump:
			initiate_climb()
		move(delta, input_axis, input_jump, input_crouch, input_sprint, input_swim_down, input_swim_up)
	else:
		# NOTE: It is important to always call move() even if we have no inputs 
		## to process, as we still need to calculate gravity and collisions.
		move(delta)	
	detect_idle(delta)

func update_view_marker()->void:
	var projection_point_on_window:Vector2 = Vector2(camera_3d.get_window().size.x/2, camera_3d.get_window().size.y/2)
	projected_view_marker = camera_3d.project_position(projection_point_on_window, 20)

func is_rate_limit_enforced()->bool:
	if object_uptime < 1.0:
		return true
	if is_actions_rate_limited && enforce_rate_limit:
		return true
	return false

## This is the flat rate limit allowed for input on actions.
## This does not represent the rate limit connected to the 
## length of the animation.
func rate_limit_actions():
	if is_actions_rate_limited:
		return
	is_actions_rate_limited = true
	rate_limit_timer.one_shot = true
	rate_limit_timer.start(action_rate_limit_time)
	await rate_limit_timer.timeout
	is_actions_rate_limited = false
	enforce_rate_limit = false

func setup_animation_library():
	var animation_paths:Array = ObjectIndex.object_index.get_all_animation_paths()
	for animation_path in animation_paths:
		avatar.add_animation(animation_path)

func enter_display_mode():
	pass
	
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
	build_interactor.enter_placement_mode(object_category, object_id)

## Runs by physics process. Will set idle to true when no interupting conditions occur.
func detect_idle(delta:float):
	if position == last_position:
		time_idling += delta
		if not has_player_stopped:
			has_player_stopped = true
			emit_player_stopped.rpc()
	else:
		has_player_stopped = false
		break_idle()
	last_position = position
	
	if time_idling >= long_idle_time && !is_long_idle:
		start_long_idle()
		return #return here so as not to test long idle.
		
	if time_idling >= short_idle_time && \
	!is_short_idle && \
	!is_moving && \
	!is_running && \
	!is_crouched:
		start_short_idle()

func start_long_idle():
	is_long_idle = true

func start_short_idle():
	is_short_idle = true

func is_idle()->bool:
	if is_short_idle:
		return true
	if is_long_idle:
		return true
	return false

func initiate_climb():
	input_jump = false
	if climb_sensor.is_step_up_available:
		do_action_step_up.emit()
	if climb_sensor.is_climb_up_available:
		do_action_climb_up.emit()

func break_idle():
	time_idling = 0
	if is_short_idle:
		is_short_idle = false		
	
	if is_long_idle:
		is_long_idle = false
	if not player_moved_signaled:
		emit_player_moved.rpc()

func do_process_climb_up(process_time:float):
	is_climbing_up = true
	climb_up_time = process_time
	var tween = get_tree().create_tween()
	var destination:Vector3 = climb_sensor.get_climb_target()+Vector3.UP
	tween.tween_property(self, "global_position", destination, process_time).set_trans(Tween.TransitionType.TRANS_QUAD)
	

func do_process_step_up(process_time:float):
	step_up_time = process_time
	is_stepping_up = true
	var tween = get_tree().create_tween()
	var destination:Vector3 = climb_sensor.get_climb_target()+Vector3.UP
	tween.tween_property(self, "global_position", destination, process_time).set_trans(Tween.TransitionType.TRANS_CIRC)
	
	
func stop_process_climb_up():
	is_climbing_up = false
	climb_up_time_elapsed = 0

func stop_process_step_up():
	is_stepping_up = false
	step_up_time_elapsed = 0

@rpc("any_peer", "call_local", "unreliable")
func emit_player_moved():
	player_moved.emit()

@rpc("any_peer", "call_local", "unreliable")
func emit_player_stopped():
	player_stopped.emit()

func acknowledge_player_moved_signal():
	player_moved_signaled = true
	player_stopped_signaled = false

func acknowledge_player_stopped_signal():
	player_moved_signaled = false
	player_stopped_signaled = true

func get_spawner_node()->Node3D:
	return spawner_node

func get_peer_id()->int:
	return peer_id

func get_camera()->Camera3D:
	return camera_3d

## The main entry point for equipping object to a slot.
func equip(id:int):
	if not avatar.is_node_ready():
		await avatar.ready
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
		var meta:Dictionary = {"id":id}
		
		avatar.equip(slot, path, meta)

func unequip(slot:String):
	set(slot, -1)

#region ACTION PRIMARY TRIGGERS
func trigger_action_primary():
	if is_rate_limit_enforced():
		await rate_limit_timer.timeout
	rate_limit_actions()
	do_action_primary.rpc()
	enforce_rate_limit = true

func end_action_primary():
	do_action_primary.rpc(false)

@rpc("any_peer", "call_local", "reliable")
func do_action_primary(on:bool = true):
	break_idle()
	primary_action_pressed.emit(on)
#endregion ACTION PRIMARY TRIGGERS

#region ACTION SECONDARY TRIGGERS
func trigger_action_secondary():
	if is_rate_limit_enforced():
		await rate_limit_timer.timeout
	rate_limit_actions()
	do_action_secondary.rpc()
	enforce_rate_limit = true

func end_action_secondary():
	do_action_secondary.rpc(false)

@rpc("any_peer", "call_local", "reliable")
func do_action_secondary(on:bool = true):
	break_idle()
	secondary_action_pressed.emit(on)
#endregion ACTION SECONDARY TRIGGERS

#region ACTION PRIMARY ALT TRIGGERS
func trigger_action_primary_alt():
	if is_rate_limit_enforced():
		await rate_limit_timer.timeout
	rate_limit_actions()
	do_action_primary_alt.rpc()
	enforce_rate_limit = true

func end_action_primary_alt():
	do_action_primary_alt.rpc(false)

@rpc("any_peer", "call_local", "reliable")
func do_action_primary_alt(on:bool = true):
	break_idle()
	primary_action_alt_pressed.emit(on)

#endregion ACTION PRIMARY ALT TRIGGERS

#region ACTION SECONDARY ALT TRIGGERS
func trigger_action_secondary_alt():
	if is_rate_limit_enforced():
		await rate_limit_timer.timeout
	rate_limit_actions()
	do_action_secondary_alt.rpc()
	enforce_rate_limit = true

func end_action_secondary_alt():
	do_action_secondary_alt.rpc(false)

@rpc("any_peer", "call_local", "reliable")
func do_action_secondary_alt(on:bool = true):
	break_idle()
	seconary_action_alt_pressed.emit(on)
#endregion ACTION SECONDARY ALT TRIGGERS

#region ACTION BASIC INTERACT TRIGGERS
func trigger_action_basic_interact():
	if is_rate_limit_enforced():
		await rate_limit_timer.timeout
	rate_limit_actions()
	do_action_basic_interact.rpc()
	enforce_rate_limit = true

func end_action_basic_interact():
	do_action_basic_interact.rpc(false)

@rpc("any_peer", "call_local", "reliable")
func do_action_basic_interact(on:bool = true):
	break_idle()
	do_action_basic_interact_pressed.emit(on)
#endregion ACTION BASIC INTERACT TRIGGERS

#func _on_controller_emerged():
	#camera.environment = null
#
#
#func _on_controller_subemerged():
	#camera.environment = underwater_env
