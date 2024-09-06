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
}


## The main function for coordinating actoins with animations.
func coordinate_action(action_type:ActionType)->void:
	match action_type:
		ActionType.BASIC_INTERACTION:
			pass
		ActionType.PRIMARY_ACTION:
			pass
		ActionType.SECONDARY_ACTION:
			pass
		ActionType.PRIMARY_ACTION_ALT:
			pass
		ActionType.SECONDARY_ACTION_ALT:
			pass

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
