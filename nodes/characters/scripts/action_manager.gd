extends Node3D

## Coordinates animations with actions. Acts like a manager relaying
## actions to the related systems.
class_name ActionManager

enum ActionType{
	BASIC_INTERACTION,
	PRIMARY_ACTION,
	SECONDARY_ACTION,
	PRIMARY_ACTION_ALT,
	SECONDARY_ACTION_ALT,
	SHORT_IDLE,
	LONG_IDLE,
	END_MOVE,
	START_MOVE,
	CLIMB_UP,
	STEP_UP,
	NONE,
}

@export var player: Player
@export var avatar: Avatar 

#region authoritative action signals
signal aiming(aiming:bool)
var is_aiming:bool = false
var is_aimable:bool = false

var is_primary_action_engaged:bool = false
signal primary_action_engaged(on:bool)

var is_secondary_action_engaged:bool = false
signal secondary_action_engaged(on:bool)

var is_primary_action_alt_engaged:bool = false
signal primary_action_alt_engaged(on:bool)

var is_secondary_action_alt_engaged:bool = false
signal secondary_action_alt_engaged(on:bool)

var is_basic_interact_engaged:bool = false
signal basic_interact_engaged(on:bool)
#endregion 

#region default animations
@export var default_basic_interaction_animation_id:int=0
@export var default_primary_action_animation_id:int=0
@export var default_secondary_action_animation_id:int=0
@export var default_primary_action_alt_animation_id:int=0
@export var default_secondary_action_alt_animation_id:int=0
@export var default_short_idle_animation_id:int=0
@export var default_long_idle_animation_id:int=0

@export var default_basic_interaction_animation_mask:String=""
@export var default_primary_action_animation_mask:String=""
@export var default_secondary_action_animation_mask:String=""
@export var default_primary_action_alt_animation_mask:String=""
@export var default_secondary_action_alt_animation_mask:String=""
@export var default_short_idle_animation_mask:String=""
@export var default_long_idle_animation_mask:String=""
#endregion

#region climb animations 
@export var step_up_animation_id:int
@export var climb_up_animation_id:int
@export var step_up_animation_mask:String = "FULL"
@export var climb_up_animation_mask:String = "FULL" 
#endregion


#region altered_animations
var basic_interaction_animation_id:int=0
var primary_action_animation_id:int=0
var secondary_action_animation_id:int=0
var primary_action_alt_animation_id:int=0
var secondary_action_alt_animation_id:int=0
var short_idle_animation_id:int=0
var long_idle_animation_id:int=0

var basic_interaction_animation_mask:String="TORSO"
var primary_action_animation_mask:String="TORSO"
var secondary_action_animation_mask:String="TORSO"
var primary_action_alt_animation_mask:String="FULL"
var secondary_action_alt_animation_mask:String="FULL"
var short_idle_animation_mask:String="TORSO"
var long_idle_animation_mask:String="FULL"
#endregion 

#region rate limiting
var rate_limited_action_type = ActionType.NONE
var is_rate_limited:bool = false
signal rate_limit_enforced
signal rate_limit_released
#endregion 


#region testing
@export var testing:bool = false
#endregion 

func _ready() -> void:
	if not avatar.get_character_appearance().is_node_ready():
		await avatar.get_character_appearance().ready
	player.do_action_step_up.connect(_on_do_action_step_up_initiated)
	player.do_action_climb_up.connect(_on_do_action_climb_up_initiated)
	avatar.get_character_appearance().pre_slot_equiped.connect(_on_character_appearance_pre_slot_equiped)
	avatar.get_character_appearance().post_slot_equiped.connect(_on_character_appearance_post_slot_equiped)
	avatar.get_animation_tree().play_animation_complete.connect(_on_action_complete)
	secondary_action_engaged.connect(check_stop_aiming)
	aiming.connect(do_aiming_loop)
	aiming.connect(position_object_to_aim)
	complete_action()

## The main function for coordinating actions with animations.
func coordinate_action(action_type:ActionType, bypass_rate_limit:bool = false)->void:
	if testing:
		print(ActionType.keys()[action_type])
	if is_rate_limited && !bypass_rate_limit:
		return
	if bypass_rate_limit && is_rate_limited:
		await rate_limit_released
	if avatar == null:
		return
	if not avatar.is_node_ready():
		await avatar.ready
	var animation_name:String = ""
	var default_animation_name:String = ""
	var rate_limit_actions = false

	match action_type:
		
		ActionType.BASIC_INTERACTION:
			if not is_basic_interact_engaged:
				basic_interact_engaged.emit(true)
			default_animation_name = ObjectIndex.object_index.get_animation_name(default_basic_interaction_animation_id)
			animation_name = ObjectIndex.object_index.get_animation_name(basic_interaction_animation_id, default_animation_name)
			avatar.play_animation(animation_name, basic_interaction_animation_mask)
			is_basic_interact_engaged = true
			rate_limit_actions = true
		
		ActionType.PRIMARY_ACTION:
			if not is_primary_action_engaged:
				primary_action_engaged.emit(true)
			default_animation_name = ObjectIndex.object_index.get_animation_name(default_primary_action_animation_id)
			animation_name = ObjectIndex.object_index.get_animation_name(primary_action_animation_id, default_animation_name)
			avatar.play_animation(animation_name, primary_action_animation_mask)
			is_primary_action_engaged = true
			rate_limit_actions = true
		
		ActionType.SECONDARY_ACTION:
			var loop:bool = false
			if not is_secondary_action_engaged:
				secondary_action_engaged.emit(true)
			if is_aimable && not is_aiming:
				aiming.emit(true)
				loop = true			
			default_animation_name = ObjectIndex.object_index.get_animation_name(default_secondary_action_animation_id)
			animation_name = ObjectIndex.object_index.get_animation_name(secondary_action_animation_id, default_animation_name)
			avatar.play_animation(animation_name, secondary_action_animation_mask, loop)
			is_secondary_action_engaged = true
			rate_limit_actions = true
			
		ActionType.PRIMARY_ACTION_ALT:
			if not is_primary_action_alt_engaged:
				primary_action_alt_engaged.emit(true)
			default_animation_name = ObjectIndex.object_index.get_animation_name(default_primary_action_alt_animation_id)
			animation_name = ObjectIndex.object_index.get_animation_name(primary_action_alt_animation_id, default_animation_name)
			avatar.play_animation(animation_name, primary_action_alt_animation_mask)
			is_primary_action_alt_engaged = true
			rate_limit_actions = true
		
		ActionType.SECONDARY_ACTION_ALT:
			if not is_secondary_action_alt_engaged:
				secondary_action_alt_engaged.emit(true)
			default_animation_name = ObjectIndex.object_index.get_animation_name(default_secondary_action_alt_animation_id)
			animation_name = ObjectIndex.object_index.get_animation_name(secondary_action_alt_animation_id, default_animation_name)
			avatar.play_animation(animation_name, secondary_action_alt_animation_mask)
			is_secondary_action_alt_engaged = true
			rate_limit_actions = true
		
		# OTHER
		
		ActionType.SHORT_IDLE:
			if not player.is_moving:
				play_short_idle_animation()
		
		ActionType.LONG_IDLE:
			if not player.is_moving:
				default_animation_name = ObjectIndex.object_index.get_animation_name(default_long_idle_animation_id)
				animation_name = ObjectIndex.object_index.get_animation_name(long_idle_animation_id, default_animation_name)
				avatar.play_animation(animation_name, long_idle_animation_mask, true)
		
		ActionType.END_MOVE:
			#avatar.play_animation("")
			if is_rate_limited:
				await rate_limit_released
			avatar.animation_tree.stop_animation()
		
		ActionType.START_MOVE:
			if is_rate_limited:
				await rate_limit_released
			avatar.stop_animation()
			
		ActionType.CLIMB_UP:
			animation_name = ObjectIndex.object_index.get_animation_name(climb_up_animation_id)
			avatar.play_animation(animation_name, climb_up_animation_mask)
			do_climb_up_process(avatar.animation_tree.get_animation_length(animation_name))
			rate_limit_actions = true
			
		ActionType.STEP_UP:
			animation_name = ObjectIndex.object_index.get_animation_name(step_up_animation_id)
			avatar.play_animation(animation_name, step_up_animation_mask)
			do_step_up_process(avatar.animation_tree.get_animation_length(animation_name))
			rate_limit_actions = true
		_:
			play_short_idle_animation()

	if rate_limit_actions:
		rate_limited_action_type = action_type
		var animation_length = avatar.get_animation_tree().get_animation_length(animation_name)
		rate_limit_action(animation_length)

## Changes an action animation based on equipped item.
func change_action_animation(_slot: CharacterAppearance.Equippable, meta: Dictionary):
	if meta.is_empty():
		return
	if not meta.has("id"):
		return
	var ob:Node = ObjectIndex.get_object("items", meta["id"])
	if ob == null:
		return
	basic_interaction_animation_id = ob.get_meta("basic_interaction_animation_id", default_basic_interaction_animation_id)
	primary_action_animation_id = ob.get_meta("primary_action_animation_id", default_primary_action_animation_id)
	secondary_action_animation_id = ob.get_meta("secondary_action_animation_id", default_secondary_action_animation_id)
	primary_action_alt_animation_id = ob.get_meta("primary_action_alt_animation_id", default_primary_action_alt_animation_id)
	secondary_action_alt_animation_id = ob.get_meta("secondary_action_alt_animation_id", default_secondary_action_alt_animation_id)
	
	basic_interaction_animation_mask = ob.get_meta("basic_interaction_animation_mask", default_basic_interaction_animation_mask)
	primary_action_animation_mask = ob.get_meta("primary_action_animation_mask", default_primary_action_animation_mask)
	secondary_action_animation_mask = ob.get_meta("secondary_action_animation_mask", default_secondary_action_animation_mask)
	primary_action_alt_animation_mask= ob.get_meta("primary_action_alt_animation_mask", default_primary_action_alt_animation_mask)
	secondary_action_alt_animation_mask = ob.get_meta("secondary_action_alt_animation_mask", default_secondary_action_alt_animation_mask)

# TODO
## Changes the idle animation associated with the item, such as an Ax or Food Item
func change_short_idle_animation(slot: CharacterAppearance.Equippable, meta: Dictionary):
	if slot != CharacterAppearance.Equippable.SLOT_34:
		return
	if meta.is_empty():
		return
	if not meta.has("id"):
		return
	var ob:Node = ObjectIndex.get_object("items", meta["id"])
	if ob == null:
		return
	short_idle_animation_id = ob.get_meta("short_idle_animation_id", default_short_idle_animation_id)
	short_idle_animation_mask = ob.get_meta("short_idle_animation_mask", default_short_idle_animation_mask)
	play_short_idle_animation()

func play_short_idle_animation():
	await get_tree().process_frame
	var default_animation_name = ObjectIndex.object_index.get_animation_name(default_short_idle_animation_id)
	var animation_name = ObjectIndex.object_index.get_animation_name(short_idle_animation_id, default_animation_name)
	if not avatar.is_playing_animation(animation_name):
		avatar.play_animation(animation_name, short_idle_animation_mask, true)

## After much consideration, only a slot 34 item can be aimed. The presense of 
## an aimable in slot 34 enables aim mode, which loops-back the animation 
## associated with Secondary Action, the animation being a mere pose of 
## the character aiming.
func detect_aimable(slot: CharacterAppearance.Equippable, meta: Dictionary):
	if slot != CharacterAppearance.Equippable.SLOT_34:
		# this is not a slot that can have aiming applied.
		return
	if not meta.has("id"):
		return 
	var id:int = meta["id"]
	var ob:Node3D = ObjectIndex.get_object("items", id)	
	is_aimable = ob.has_meta("anchor_slot_34_position_aiming")

	
## The much-anticipated end-process function of applying the 
## offset from the object's meta to the transform of object in anchor.
func apply_slot_offset(slot: CharacterAppearance.Equippable, meta: Dictionary):
	if slot not in range(27,35):
		# this is not an anchorable slot.
		return
	if not meta.has("id"):
		return 
	var id:int = meta["id"]
	var ob = ObjectIndex.get_object("items", id)	
	var anchor_slot_position:Vector3 = ob.get_meta("anchor_slot_%s_position"%str(slot), Vector3.ZERO)
	var anchor_slot_rotation:Vector3 = ob.get_meta("anchor_slot_%s_rotation"%str(slot), Vector3.ZERO)
	var object_in_slot:Node3D = avatar.character_appearance.get_slot_object(slot)
	object_in_slot.position = anchor_slot_position
	object_in_slot.rotation_degrees = anchor_slot_rotation

func rate_limit_action(time:float):
	is_rate_limited = true
	rate_limit_enforced.emit()
	await get_tree().create_timer(time).timeout
	is_rate_limited = false
	rate_limited_action_type = ActionType.NONE
	rate_limit_released.emit()

#region Aiming...
func do_aiming_loop(_aiming:bool):
	if _aiming:
		start_aim_loop()
	else:
		stop_aim_loop()

func start_aim_loop():
	is_aiming = true

func stop_aim_loop():
	is_aiming = false
	
func position_object_to_aim(_aiming:bool):
	var object_in_slot:Node3D = avatar.character_appearance.get_slot_object(34)
	if object_in_slot == null:
		return
	if _aiming:
		object_in_slot.position = object_in_slot.get_meta("anchor_slot_34_position_aiming", object_in_slot.position)
		object_in_slot.rotation_degrees = object_in_slot.get_meta("anchor_slot_34_rotation_aiming", object_in_slot.rotation_degrees)
	else:
		object_in_slot.position = object_in_slot.get_meta("anchor_slot_34_position", object_in_slot.position)
		object_in_slot.rotation_degrees = object_in_slot.get_meta("anchor_slot_34_rotation", object_in_slot.rotation_degrees)

func check_stop_aiming(_aiming:bool):
	if not _aiming:		
		aiming.emit(false)
		coordinate_action(ActionType.SHORT_IDLE, true)
	
#endregion 

#region climbing
func do_step_up_process(process_time:float):
	player.step_up_started.emit(process_time)
	await get_tree().create_timer(process_time).timeout
	player.step_up_stopped.emit()

func do_climb_up_process(process_time:float):
	player.climb_up_started.emit(process_time)
	await get_tree().create_timer(process_time).timeout
	player.climb_up_stopped.emit()
#endregion 

#region signal listeners
## Simply relays the action to the coordinate_action function.
## Signal connected from root Player class.
func _on_player_do_action_basic_interact_pressed(on:bool = true) -> void:
	if not on && is_basic_interact_engaged:
		is_basic_interact_engaged = false
		basic_interact_engaged.emit(false)
		return
	coordinate_action(ActionType.BASIC_INTERACTION)

## Simply relays the action to the coordinate_action function.
## Signal connected from root Player class.
func _on_player_primary_action_alt_pressed(on:bool = true) -> void:
	if not on && is_primary_action_alt_engaged:
		is_basic_interact_engaged = false
		primary_action_alt_engaged.emit(false)		
		return
	coordinate_action(ActionType.PRIMARY_ACTION_ALT)

## Simply relays the action to the coordinate_action function.
## Signal connected from root Player class.
func _on_player_primary_action_pressed(on:bool = true) -> void:
	if not on && is_primary_action_engaged:
		is_primary_action_engaged = false
		primary_action_engaged.emit(false)
		return
	coordinate_action(ActionType.PRIMARY_ACTION)

## Simply relays the action to the coordinate_action function.
## Signal connected from root Player class.
func _on_player_seconary_action_alt_pressed(on:bool = true) -> void:
	if not on && is_secondary_action_alt_engaged:
		is_secondary_action_alt_engaged = false
		secondary_action_alt_engaged.emit(false)
		return
	coordinate_action(ActionType.SECONDARY_ACTION_ALT)

## Simply relays the action to the coordinate_action function.
## Signal connected from root Player class.
func _on_player_secondary_action_pressed(on:bool = true) -> void:
	if not on && is_secondary_action_engaged:
		is_secondary_action_engaged = false
		secondary_action_engaged.emit(false)
		return
	coordinate_action(ActionType.SECONDARY_ACTION)

func _on_player_is_long_idle_changed(_value: Variant) -> void:
	coordinate_action(ActionType.LONG_IDLE, true)

func _on_player_is_short_idle_changed(value: Variant) -> void:
	#coordinate_action(ActionType.SHORT_IDLE)
	pass

## When player stops walking or running, we assure that the 
## custom animation runs, if he is carrying a knife, gun, etc.
func _on_player_player_stopped() -> void:
	coordinate_action(ActionType.END_MOVE, true)
	coordinate_action(ActionType.SHORT_IDLE, true)

func _on_player_player_moved() -> void:
	coordinate_action(ActionType.START_MOVE, true)

func complete_action():
	if is_rate_limited:
		await rate_limit_released
	_on_action_complete()
	
func _on_action_complete():
	if is_rate_limited:
		await rate_limit_released
		
	coordinate_action(ActionType.SHORT_IDLE)

func _on_character_appearance_pre_slot_equiped(slot: CharacterAppearance.Equippable, meta: Dictionary) -> void:
	change_action_animation(slot, meta)
	change_short_idle_animation(slot, meta)

func _on_character_appearance_post_slot_equiped(slot: CharacterAppearance.Equippable, meta: Dictionary) -> void:
	apply_slot_offset(slot, meta)
	detect_aimable(slot, meta)

## This is first triggered in the Console or UI. It changes the personality 
## aka long idle of the character.
func _on_player_personality_id_changed(value: int) -> void:
	long_idle_animation_id = value
	if player.display_mode:
		coordinate_action(ActionType.LONG_IDLE)
		
func _on_do_action_step_up_initiated():
	coordinate_action(ActionType.STEP_UP)
	
func _on_do_action_climb_up_initiated():
	coordinate_action(ActionType.CLIMB_UP)
	
#endregion 
