extends Node

## class_name is PlayerInput.
## Handles the main input of the player, and differentiates
## between different modes, such as Player, UI, Vehicles, etc.

enum InputMode{
	NONE,
	CHARACTER_INPUT,
	VEHICLE_INPUT,
	UI_INPUT,
}

var input_mode = InputMode.CHARACTER_INPUT

#region shared vars
signal primary_action_held(held:bool)
signal secondary_action_held(held:bool)
signal primary_action_alt_held(held:bool)
signal secondary_action_alt_held(held:bool)
signal basic_interaction_held(held:bool)

var is_primary_action_held:bool = false
var primary_action_held_time:float = 0
var is_secondary_action_held:bool = false
var secondary_action_held_time:float = 0
var is_primary_action_alt_held:bool = false
var primary_action_alt_held_time:float = 0
var is_secondary_action_alt_held:bool = false
var secondary_action_alt_held_time:float = 0
var is_basic_interaction_held:bool = false
var basic_interaction_held_time:float = 0
#endregion 

#region character input vars
signal head_motion_relative_changed(head_motion:Vector2)
signal primary_action_pressed
signal secondary_action_pressed
signal primary_action_alt_pressed
signal secondary_action_alt_pressed
signal action_basic_interact_pressed

signal primary_action_released
signal secondary_action_released
signal primary_action_alt_released
signal secondary_action_alt_released
signal action_basic_interact_released


var primary_action_active:bool = false
var secondary_action_active:bool = false
var primary_action_alt_active:bool = false
var secondary_action_alt_active:bool = false
var basic_interaction_active:bool = false

var hold_action_time_threshold:float = 0.5

## This is registered in the Player object in the _ready function.
var character:Player = null
var is_valid_player_input:bool = true

var input_back_action_name := "move_backward"
var input_forward_action_name := "move_forward"
var input_left_action_name := "move_left"
var input_right_action_name := "move_right"
var input_sprint_action_name := "move_sprint"
var input_jump_action_name := "move_jump"
var input_crouch_action_name := "move_crouch"
var input_fly_mode_action_name := "move_fly_mode"

var input_axis:Vector2 = Vector2.ZERO
var input_jump:bool = false
var input_crouch:bool = false
var input_sprint:bool = false
var input_swim_down:bool = false
var input_swim_up:bool = false
var fly_mode_toggled:bool = false

@export var testing = false

## This directly correlates to event.relative in mouse motion events. 
var head_motion_relative:Vector2 = Vector2.ZERO:
	set(value):
		head_motion_relative = value
		head_motion_relative_changed.emit(value)
#endregion 

#region vehicle input vars
#endregion 

#region ui input vars
#endregion 

func _ready() -> void:
	if testing:
		primary_action_held.connect(_on_primary_action_held)
		secondary_action_held.connect(_on_secondary_action_held)
		primary_action_alt_held.connect(_on_primary_action_alt_held)
		secondary_action_alt_held.connect(_on_secondary_action_alt_held)
		basic_interaction_held.connect(_on_basic_interaction_held)

func _process(delta: float) -> void:
	update_action_held_status(delta)

func _input(event: InputEvent) -> void:
		
	match input_mode:
		InputMode.NONE:
			pass
		InputMode.CHARACTER_INPUT:
			process_character_input(event)
		InputMode.VEHICLE_INPUT:
			process_vehicle_input(event)
		InputMode.UI_INPUT:
			process_ui_input(event)
			
#region CHARACTER
func process_character_input(event:InputEvent):
	if character == null:
		return
	if not character.is_multiplayer_authority():
		return
	is_valid_player_input = Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if is_valid_player_input:
		fly_mode_toggled = Input.is_action_just_pressed(input_fly_mode_action_name)
		input_axis = Input.get_vector(input_left_action_name, input_right_action_name, input_back_action_name, input_forward_action_name)
		input_jump = Input.is_action_just_pressed(input_jump_action_name)
		input_crouch = Input.is_action_pressed(input_crouch_action_name)
		input_sprint = Input.is_action_pressed(input_sprint_action_name)
		input_swim_down = Input.is_action_pressed(input_crouch_action_name)
		input_swim_up = Input.is_action_pressed(input_jump_action_name)
	
	# This sets the head in motion based on the head_motion_relative.changed signal which the Player
	# object subscribes to
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head_motion_relative = event.relative
	# ACTIONS 
	

	if event is InputEventMouseButton:
		# Actions Released
		if event.is_action_released("left_mouse_button_alt") && primary_action_alt_active:
			primary_action_alt_released.emit()
			primary_action_alt_active = false
			return
		if event.is_action_released("right_mouse_button_alt") && secondary_action_alt_active:
			secondary_action_alt_released.emit()
			secondary_action_alt_active = false
			return
		if event.is_action_released("left_mouse_button") && primary_action_active:
			primary_action_released.emit()
			primary_action_active = false
			return
		if event.is_action_released("right_mouse_button") && secondary_action_active:
			secondary_action_released.emit()
			secondary_action_active = false
			return
			
		# Actions Engaged
		if event.is_action_pressed("left_mouse_button_alt"):
			primary_action_alt_pressed.emit()
			primary_action_alt_active = true
			return
		if event.is_action_pressed("right_mouse_button_alt"):
			secondary_action_alt_pressed.emit()
			secondary_action_alt_active = true
			return
		if event.is_action_pressed("left_mouse_button"):
			primary_action_pressed.emit()
			primary_action_active = true
			return
		if event.is_action_pressed("right_mouse_button"):
			secondary_action_pressed.emit()
			secondary_action_active = true
			return
			
	if event is InputEventKey:
		if event.is_action_released("basic_interact") && basic_interaction_active:
			action_basic_interact_released.emit()
			basic_interaction_active = false
			
		if event.is_action_pressed("basic_interact"):
			action_basic_interact_pressed.emit()
			basic_interaction_active = true

func update_action_held_status(delta:float):
	update_primary_action_held(delta)
	update_secondary_action_held(delta)
	update_primary_action_alt_held(delta)
	update_secondary_action_alt_held(delta)
	update_basic_interaction_held(delta)

func update_primary_action_held(delta:float):
	if not primary_action_active:
		if is_primary_action_held:
			is_primary_action_held = false
			primary_action_held_time = 0
			primary_action_held.emit(false)
		return
	primary_action_held_time += delta
	if primary_action_held_time >= hold_action_time_threshold && !is_primary_action_held:
		is_primary_action_held = true
		primary_action_held.emit(true)
		
func update_secondary_action_held(delta:float):
	if not secondary_action_active:
		if is_secondary_action_held:
			is_secondary_action_held = false
			secondary_action_held_time = 0
			secondary_action_held.emit(false)
		return
	secondary_action_held_time += delta
	if secondary_action_held_time >= hold_action_time_threshold && !is_secondary_action_held:
		is_secondary_action_held = true
		secondary_action_held.emit(true)

func update_primary_action_alt_held(delta:float):
	if not primary_action_alt_active:
		if is_primary_action_alt_held:
			is_primary_action_alt_held = false
			primary_action_alt_held_time = 0
			primary_action_alt_held.emit(false)
		return
	primary_action_alt_held_time += delta
	if primary_action_alt_held_time >= hold_action_time_threshold && !is_primary_action_alt_held:
		is_primary_action_alt_held = true
		primary_action_alt_held.emit(true)
		
func update_secondary_action_alt_held(delta:float):
	if not secondary_action_alt_active:
		if is_secondary_action_alt_held:
			is_secondary_action_alt_held = false
			secondary_action_alt_held_time = 0
			secondary_action_alt_held.emit(false)
		return
	secondary_action_alt_held_time += delta
	if secondary_action_alt_held_time >= hold_action_time_threshold && !is_secondary_action_alt_held:
		is_secondary_action_alt_held = true
		secondary_action_alt_held.emit(true)

func update_basic_interaction_held(delta:float):
	if not basic_interaction_active:
		if is_basic_interaction_held:
			is_basic_interaction_held = false
			basic_interaction_held_time = 0
			basic_interaction_held.emit(false)
		return
	basic_interaction_held_time += delta
	if basic_interaction_held_time >= hold_action_time_threshold && !is_basic_interaction_held:
		is_basic_interaction_held = true
		basic_interaction_held.emit(true)

func register_character_object(_character:Player):
	character = _character
#endregion 

## TESTING HELD ACTIONS
func _on_primary_action_held(held:bool):
	if held:
		print("Primary interaction held...")
	else:
		print("Primary interaction released...")
func _on_secondary_action_held(held:bool):
	if held:
		print("Secondary interaction held...")
	else:
		print("Secondary interaction released...")
func _on_primary_action_alt_held(held:bool):
	if held:
		print("Primary (alt) interaction held...")
	else:
		print("Primary (alt) interaction released...")
func _on_secondary_action_alt_held(held:bool):
	if held:
		print("Secondary (alt) interaction held...")
	else:
		print("Secondary (alt) interaction released...")
func _on_basic_interaction_held(held:bool):
	if held:
		print("Basic interaction held...")
	else:
		print("Basic interaction released...")

#region VEHICLE
func process_vehicle_input(event:InputEvent):
	pass
#endregion 

#region UI
func process_ui_input(event:InputEvent):
	pass
#endregion 
