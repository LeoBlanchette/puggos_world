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
	LONG_IDLE,
}

@onready var player: Player = $".."
@onready var avatar: Avatar = $"../Avatar"

#region default animations
@export var default_basic_interaction_animation_id:int=0
@export var default_primary_action_animation_id:int=0
@export var default_secondary_action_animation_id:int=0
@export var default_primary_action_alt_animation_id:int=0
@export var default_secondary_action_alt_animation_id:int=0
@export var default_long_idle_animation_id:int=0

@export var default_basic_interaction_animation_mask:String=""
@export var default_primary_action_animation_mask:String=""
@export var default_secondary_action_animation_mask:String=""
@export var default_primary_action_alt_animation_mask:String=""
@export var default_secondary_action_alt_animation_mask:String=""
@export var default_long_idle_animation_mask:String=""
#endregion

#region altered_animations
var basic_interaction_animation_id:int=0
var primary_action_animation_id:int=0
var secondary_action_animation_id:int=0
var primary_action_alt_animation_id:int=0
var secondary_action_alt_animation_id:int=0
var long_idle_animation_id:int=0

var basic_interaction_animation_mask:String="TORSO"
var primary_action_animation_mask:String="TORSO"
var secondary_action_animation_mask:String="TORSO"
var primary_action_alt_animation_mask:String="FULL"
var secondary_action_alt_animation_mask:String="FULL"
var long_idle_animation_mask:String="FULL"
#endregion 

## The main function for coordinating actions with animations.
func coordinate_action(action_type:ActionType)->void:
	if avatar == null:
		return
	if not avatar.is_node_ready():
		await avatar.ready
	var animation_name:String = ""
	var default_animation_name:String = ""
	match action_type:
		ActionType.BASIC_INTERACTION:
			default_animation_name = ObjectIndex.object_index.get_animation_name(default_basic_interaction_animation_id)
			animation_name = ObjectIndex.object_index.get_animation_name(basic_interaction_animation_id, default_animation_name)
			avatar.play_animation(animation_name, basic_interaction_animation_mask)
		ActionType.PRIMARY_ACTION:
			default_animation_name = ObjectIndex.object_index.get_animation_name(default_primary_action_animation_id)
			animation_name = ObjectIndex.object_index.get_animation_name(primary_action_animation_id, default_animation_name)
			avatar.play_animation(animation_name, primary_action_animation_mask)
		ActionType.SECONDARY_ACTION:
			default_animation_name = ObjectIndex.object_index.get_animation_name(default_secondary_action_animation_id)
			animation_name = ObjectIndex.object_index.get_animation_name(secondary_action_animation_id, default_animation_name)
			avatar.play_animation(animation_name, secondary_action_animation_mask)
		ActionType.PRIMARY_ACTION_ALT:
			default_animation_name = ObjectIndex.object_index.get_animation_name(default_primary_action_alt_animation_id)
			animation_name = ObjectIndex.object_index.get_animation_name(primary_action_alt_animation_id, default_animation_name)
			avatar.play_animation(animation_name, primary_action_alt_animation_mask)
		ActionType.SECONDARY_ACTION_ALT:
			default_animation_name = ObjectIndex.object_index.get_animation_name(default_secondary_action_alt_animation_id)
			animation_name = ObjectIndex.object_index.get_animation_name(secondary_action_alt_animation_id, default_animation_name)
			avatar.play_animation(animation_name, secondary_action_alt_animation_mask)
		ActionType.LONG_IDLE:
			default_animation_name = ObjectIndex.object_index.get_animation_name(default_long_idle_animation_id)
			animation_name = ObjectIndex.object_index.get_animation_name(long_idle_animation_id, default_animation_name)
			avatar.play_animation(animation_name, long_idle_animation_mask, true)

##Changes an action animation based on equipped item.
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


#region signal listeners
## Simply relays the action to the coordinate_action function.
## Signal connected from root Player class.
func _on_player_do_action_basic_interact_pressed() -> void:
	coordinate_action(ActionType.BASIC_INTERACTION)

## Simply relays the action to the coordinate_action function.
## Signal connected from root Player class.
func _on_player_primary_action_alt_pressed() -> void:
	coordinate_action(ActionType.PRIMARY_ACTION_ALT)

## Simply relays the action to the coordinate_action function.
## Signal connected from root Player class.
func _on_player_primary_action_pressed() -> void:
	coordinate_action(ActionType.PRIMARY_ACTION)

## Simply relays the action to the coordinate_action function.
## Signal connected from root Player class.
func _on_player_seconary_action_alt_pressed() -> void:
	coordinate_action(ActionType.SECONDARY_ACTION_ALT)

## Simply relays the action to the coordinate_action function.
## Signal connected from root Player class.
func _on_player_secondary_action_pressed() -> void:
	coordinate_action(ActionType.SECONDARY_ACTION)

func _on_player_is_long_idle_changed(_value: Variant) -> void:
	coordinate_action(ActionType.LONG_IDLE)

func _on_character_appearance_pre_slot_equiped(slot: CharacterAppearance.Equippable, meta: Dictionary) -> void:
	change_action_animation(slot, meta)

## This is first triggered in the Console or UI. It changes the personality 
## aka long idle of the character.
func _on_player_personality_id_changed(value: int) -> void:
	long_idle_animation_id = value
	if player.display_mode:
		coordinate_action(ActionType.LONG_IDLE)
#endregion 
