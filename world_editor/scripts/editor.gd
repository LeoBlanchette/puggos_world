extends Node3D
class_name Editor

const GIZMO_TSCN = preload("res://world_editor/gizmo.tscn")
const EDITOR_INTERACTOR_TSCN = preload("res://world_editor/editor_interactor.tscn")
const PLAYER_TSCN = preload("res://nodes/characters/player.tscn")
const UI_EDITOR_TSCN = preload("res://ui/ui_editor.tscn")

signal changed_transform_mode(old_mode, new_mode)
signal changed_interaction_mode(old_mode, new_mode)

var player:FPSController3D = null
var editor_interactor:EditorInteractor = null
var gizmo:EditorGizmo = null

var ui_editor:UIEditor = null

enum CurrentEditorMode{
	NONE,
	WORLD_EDITOR,
	PREFAB_EDITOR,
}

var current_editing_mode: CurrentEditorMode = CurrentEditorMode.NONE

enum InteractionMode{
	PLAY,
	EDITOR,
	PLAYER,
}

var current_interaction_mode:InteractionMode = InteractionMode.EDITOR

enum TranformMode{
	TRANSLATE,
	ROTATE,
	SCALE,
}

var current_transform_mode:TranformMode = TranformMode.TRANSLATE

static var instance:Editor = null

func _ready() -> void:
	if instance == null:
		instance = self
	else:
		queue_free()
		
	initiate()


func _exit_tree() -> void:
	if instance == self:
		instance = null
	if ui_editor != null:
		ui_editor.disconnect_signals()

func initiate():
	if get_parent().name == "WorldEditor":
		current_editing_mode = CurrentEditorMode.WORLD_EDITOR

	if get_parent().name == "PrefabEditor":
		current_editing_mode = CurrentEditorMode.PREFAB_EDITOR
	
	match current_editing_mode:
		CurrentEditorMode.WORLD_EDITOR:
			ui_editor = UI_EDITOR_TSCN.instantiate()
			UIWorldEditor.instance.add_child(ui_editor)			
			current_interaction_mode = InteractionMode.EDITOR
			enter_editor_mode()
			add_editor_gizmo()
		CurrentEditorMode.PREFAB_EDITOR:
			ui_editor = UI_EDITOR_TSCN.instantiate()
			current_interaction_mode = InteractionMode.PLAYER
			UIPrefabEditor.instance.add_child(ui_editor)
			enter_player_mode()

	# SIGNALS
	GameManager.instance.pre_level_change.connect(_on_changing_levels)
	

func switch_interaction_mode():
	var pressed_button:Button = ui_editor.interaction_mode_button_group.get_pressed_button()
	match pressed_button.name:
		"ButtonPlayMode":
			current_interaction_mode = InteractionMode.PLAY
			enter_play_mode()
		"ButtonEditorMode":
			current_interaction_mode = InteractionMode.EDITOR
			enter_editor_mode()
		"ButtonPlayerMode":
			current_interaction_mode = InteractionMode.PLAYER
			enter_player_mode()

func trigger_interaction_mode_change_signal():
	var previous_interaction_mode = current_interaction_mode
	changed_interaction_mode.emit(previous_interaction_mode, current_interaction_mode)

func switch_transform_mode():
	var pressed_button:Button = ui_editor.transform_button_group.get_pressed_button()
	var previous_transform_mode = current_transform_mode
	match pressed_button.name:
		"ButtonTranslateMode":
			current_transform_mode = TranformMode.TRANSLATE
		"ButtonRotateMode":
			current_transform_mode = TranformMode.ROTATE
		"ButtonScaleMode":
			current_transform_mode = TranformMode.SCALE			
	changed_transform_mode.emit(previous_transform_mode, current_transform_mode)

func activate_default_transform_button()->void:
	var default_button:Button = ui_editor.transform_button_group.get_buttons()[0]
	default_button.emit_signal("pressed")

func reset_interaction_objects():
	remove_player_character()
	remove_interaction_node()
	remove_gizmo()
	trigger_interaction_mode_change_signal()
	
## Enter play mode, as though game were running.
func enter_play_mode()->void:
	reset_interaction_objects()
	add_player_character()
	GameManager.instance.lock_mouse()
	trigger_interaction_mode_change_signal()
	
## Enter basic editor mode.
func enter_editor_mode()->void:
	reset_interaction_objects()
	GameManager.instance.free_mouse()
	add_interaction_node()
	add_editor_gizmo()
	trigger_interaction_mode_change_signal()
	
## Enter player build mode.
func enter_player_mode()->void:
	reset_interaction_objects()
	add_player_character()
	GameManager.instance.lock_mouse()

func _on_changing_levels(_old_level, _new_level):
	remove_current_editor()
	
func remove_current_editor():
	GameManager.instance.pre_level_change.disconnect(_on_changing_levels)
	instance = null
	queue_free()

func add_player_character():
	player = PLAYER_TSCN.instantiate()
	get_parent().call_deferred("add_child", player)
	
func remove_player_character():
	if player != null:
		player.queue_free()

func add_interaction_node():
	editor_interactor = EDITOR_INTERACTOR_TSCN.instantiate()
	add_child(editor_interactor)
	
func remove_interaction_node():
	if editor_interactor != null:
		editor_interactor.remove()

func add_editor_gizmo():
	gizmo = GIZMO_TSCN.instantiate()
	add_child(gizmo)

func remove_gizmo():
	if EditorGizmo.instance != null:
		EditorGizmo.instance.remove()
	gizmo = null
