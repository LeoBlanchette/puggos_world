extends Node3D
class_name Editor

const GIZMO_TSCN = preload("res://world_editor/gizmo.tscn")
const EDITOR_INTERACTOR_TSCN = preload("res://world_editor/editor_interactor.tscn")
const PLAYER_TSCN = preload("res://nodes/characters/player.tscn")
const UI_EDITOR_TSCN = preload("res://ui/ui_editor.tscn")

signal object_selected
signal object_selected_changed(previous:Node3D, current:Node3D)
## The XYZ values of Position, Rotation, or Scale
signal object_transform_changed
## The XYZ values of Position, Rotation, or Scale, via UI
signal object_transform_changed_ui
## Changed from translate, rotation, scale
signal changed_transform_mode(old_mode, new_mode)
signal changed_interaction_mode(old_mode, new_mode)
## Global or Local
signal changed_transform_space_mode


var player:FPSController3D = null
var editor_interactor:EditorInteractor = null
var gizmo:EditorGizmo = null

var ui_editor:UIEditor = null

enum CurrentTransformSpaceMode{
	LOCAL,
	GLOBAL
}

var current_transform_space_mode:CurrentTransformSpaceMode = CurrentTransformSpaceMode.GLOBAL:
	set(value):
		current_transform_space_mode = value
		changed_transform_space_mode.emit()


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
signal object_translated_ui(previous_position, current_position)
signal object_rotated_ui(previous_rotation, current_rotation)
signal object_scaled_ui(previous_scale, current_scale)

var previous_edited_object:Node3D = null
var edited_object:Node3D = null:
	set(value):
		previous_edited_object = edited_object
		edited_object = value
		object_selected_changed.emit(previous_edited_object, edited_object)

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
	object_translated.connect(_on_object_translated)
	object_rotated.connect(_on_object_rotated)
	object_scaled.connect(_on_object_scaled)
	object_translated_ui.connect(_on_object_translated_ui)
	object_rotated_ui.connect(_on_object_rotated_ui)
	object_scaled_ui.connect(_on_object_scaled_ui)
	GameManager.instance.pre_level_change.connect(_on_changing_levels)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("tab"):
		if Editor.instance.current_interaction_mode == Editor.InteractionMode.EDITOR:
			return
		if GameManager.instance.is_mouse_locked():
			GameManager.instance.free_mouse()
		else:
			GameManager.instance.lock_mouse()

func connect_editor_interactor():
	EditorInteractor.instance.object_selected.connect(_on_object_selected)

func disconnect_editor_interactor():
	if EditorInteractor.instance == null:
		return
	EditorInteractor.instance.object_selected.disconnect(_on_object_selected)

func clear_active_object()->void:
	edited_object = null

func get_active_object() ->Node3D:
	return edited_object

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
	disconnect_editor_interactor()
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
	disconnect_editor_interactor()
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

func unpack_prefab():
	if not Prefab.is_prefab(get_active_object()):
		return
	var prefab:Prefab = Prefab.get_prefab_root(get_active_object())
	prefab.unpack()
	clear_active_object()
	
#region object editing
func _on_object_selected(ob:Node3D)->void:
	if is_gizmo(ob):
		return
	if is_ground_plane(ob):
		Editor.instance.clear_active_object()
		if EditorGizmo.instance != null:
			EditorGizmo.instance.set_gizmo_to_clicked_space()
		return
	if is_gizmo_transforming(): #this prevents selection of overlapping objects when moving gizmo
		return

	if Prefab.is_prefab(ob):
		ob = Prefab.get_prefab_root(ob)
	
	edited_object = get_object_root(ob)

## A temporary meta assignment to give all sub objects a reference to the object root
## specified by "ob" node. Should be run after unpacking a prefab or loading mods in 
## for the first time.
func assign_object_root(ob):
	set_meta("object_root", ob.get_instance_id())
	for child:Node in HelperFunctions.get_all_children(ob):
		child.set_meta("object_root", ob.get_instance_id())

func get_object_root(ob):
	if ob == null:
		return null
	if not has_meta("object_root"):
		return ob
	var id:int = ob.get_meta("object_root", 0)
	if id == 0:
		return ob
	var root = instance_from_id(id)
	if root != null:
		return root
	return ob

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
	
func is_valid_selectable_object(ob:Node3D)->bool:
	if is_gizmo(ob):
		return false
	if is_ground_plane(ob):
		return false
	return true

func _on_object_translated(old_position:Vector3, new_position:Vector3)->void:
	if edited_object == null:
		return
	# NOTE: An UNDO can be placed here using old position. 
	edited_object.global_position = new_position
	object_transform_changed.emit()
	
func _on_object_rotated(old_rotation:Vector3, new_rotation:Vector3,)->void:
	if edited_object == null:
		return	
	# NOTE: An UNDO can be placed here using old rotation. 
	edited_object.global_rotation_degrees = new_rotation
	object_transform_changed.emit()
	
func _on_object_scaled(old_scale:Vector3, new_scale:Vector3,)->void:
	if edited_object == null:
		return	
	if Prefab.is_prefab(get_active_object()):
		Editor.instance.set_action_text("NOTE: Cannot scale a prefab.")
		return
	# NOTE: An UNDO can be placed here using old rotation. 
	edited_object.scale = new_scale
	object_transform_changed.emit()
	
func _on_object_translated_ui(old_position:Vector3, new_position:Vector3)->void:
	if edited_object == null:
		return
	# NOTE: An UNDO can be placed here using old position. 
	edited_object.global_position = new_position
	object_transform_changed_ui.emit()
	
func _on_object_rotated_ui(old_rotation:Vector3, new_rotation:Vector3,)->void:
	if edited_object == null:
		return	
	# NOTE: An UNDO can be placed here using old rotation. 
	edited_object.global_rotation_degrees = new_rotation
	object_transform_changed_ui.emit()
	
func _on_object_scaled_ui(old_scale:Vector3, new_scale:Vector3,)->void:
	if edited_object == null:
		return	
	if Prefab.is_prefab(get_active_object()):
		Editor.instance.set_action_text("NOTE: Cannot scale a prefab.")
		return
	# NOTE: An UNDO can be placed here using old rotation. 
	edited_object.scale = new_scale
	object_transform_changed_ui.emit()
#endregion

#region ui text updates
func set_action_text(text:String)->void:
	ui_editor.action_update = text
#endregion
