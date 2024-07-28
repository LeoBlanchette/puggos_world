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

signal object_translated(previous_position, current_position)
signal object_rotated(previous_rotation, current_rotation)
signal object_scaled(previous_scale, current_scale)
var edited_object:Node3D = null

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
	EditorInteractor.instance.object_selected.connect(_on_object_selected)
	object_translated.connect(_on_object_translated)
	object_rotated.connect(_on_object_rotated)
	object_scaled.connect(_on_object_scaled)
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

#region object editing
func _on_object_selected(ob:Node3D)->void:
	if is_gizmo(ob):
		return
	if is_ground_plane(ob):
		return
	if is_gizmo_transforming(): #this prevents selection of overlapping objects when moving gizmo
		return
	edited_object = ob
	print(edited_object)

func is_ground_plane(ob:Node3D)->bool:
	if ob == null:
		return false
	if ob.name == "GroundPlane":
		return true
	return false

func is_gizmo_transforming()->bool:
	if EditorGizmo.instance == null:
		return false
	if EditorGizmo.instance.is_transforming:
		return true
	return false

func is_gizmo(ob:Node3D)->bool:
	if ob == null:
		return false
	if EditorGizmo.instance == null:
		return false
	if EditorGizmo.instance.is_self_click(ob):
		return true
	return false
	
func _on_object_translated(old_position:Vector3, new_position:Vector3)->void:
	if edited_object == null:
		return
	# NOTE: An UNDO can be placed here using old position. 
	edited_object.global_position = new_position
func _on_object_rotated(old_rotation:Vector3, new_rotation:Vector3,)->void:
	if edited_object == null:
		return	
	# NOTE: An UNDO can be placed here using old rotation. 
	edited_object.global_rotation_degrees = new_rotation
	
func _on_object_scaled(old_scale:Vector3, new_scale:Vector3,)->void:
	if edited_object == null:
		return	
	# NOTE: An UNDO can be placed here using old rotation. 
	edited_object.scale = new_scale

#endregion

#region ui text updates
func set_action_text(text:String)->void:
	ui_editor.action_update = text
#endregion
