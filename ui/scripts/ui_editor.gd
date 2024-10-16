extends Control

class_name UIEditor

const SCENE_TYPE:GameManager.SCENES = GameManager.SCENES.WORLD_EDITOR

@export var modes_panel:Control
@export var controls_panel:Control

@export var interaction_mode_button_group:ButtonGroup

var view_port_mode:bool = false
@export var button_local_space: Button 

@export var action_updates_label:Label

#region object ops
@export var selected_object_label: Label 
@export var transform_button_group:ButtonGroup
@export var unpack_prefab_button:Button
#endregion 

#region mode containers
@export var object_ops: MarginContainer
@export var object_ops_right: MarginContainer 
#endregion 

var action_update:String:
	get:
		return action_updates_label.text
	set(value):
		action_updates_label.text = value

func _ready():	
	PlayerInput.input_mode = PlayerInput.InputMode.OBJECT_EDITOR_INPUT
	connect_signals()
	set_button_local_space_mode()

func _exit_tree():
	disconnect_signals()

func connect_signals():
	#TRANSFORM BUTTON GROUP
	for button in transform_button_group.get_buttons():
		if not button.is_connected("pressed", _on_transform_button_pressed):
			button.connect("pressed", _on_transform_button_pressed)
	#INTERACTION MODE BUTTON GROUP
	for button in interaction_mode_button_group.get_buttons():
		if not button.is_connected("pressed", _on_interaction_mode_button_pressed):
			button.connect("pressed", _on_interaction_mode_button_pressed)
	
	Editor.instance.changed_interaction_mode.connect(change_interaction_mode)
	Editor.instance.object_selected_changed.connect(_on_object_selected_changed)
	Editor.instance.changed_editor_context.connect(_on_editor_context_changed)

func disconnect_signals():
	#TRANSFORM BUTTON GROUP
	for button in transform_button_group.get_buttons():
		button.disconnect("pressed", _on_transform_button_pressed)
	#INTERACTION MODE BUTTON GROUP
	for button in interaction_mode_button_group.get_buttons():
		if button.is_connected("pressed", _on_interaction_mode_button_pressed):
			button.disconnect("pressed", _on_interaction_mode_button_pressed)
	if Editor.instance != null && Editor.instance.changed_interaction_mode.is_connected(change_interaction_mode):
		Editor.instance.changed_interaction_mode.disconnect(change_interaction_mode)
		Editor.instance.object_selected_changed.disconnect(_on_object_selected_changed)
		Editor.instance.changed_editor_context.disconnect(_on_editor_context_changed)
static func get_scene_type():
	return UIMain.instance.SCENE_TYPE


func _on_mouse_entered() -> void:
	view_port_mode = true
	if EditorInteractor.instance == null:
		return
	EditorInteractor.instance.entered_viewport.emit(true)

func _on_mouse_exited() -> void:
	view_port_mode = false
	if EditorInteractor.instance == null:
		return
	EditorInteractor.instance.entered_viewport.emit(false)
	
func on_object_selected(ob:Node3D):
	print(ob)

func _on_interaction_mode_button_pressed():
	if Editor.instance != null:
		Editor.instance.switch_interaction_mode()

func _on_transform_button_pressed():
	if Editor.instance != null:
		Editor.instance.switch_transform_mode()

func change_interaction_mode(_old_mode:Editor.InteractionMode, new_mode:Editor.InteractionMode):
	match new_mode:
		Editor.instance.InteractionMode.PLAY:
			enter_play_mode()
		Editor.instance.InteractionMode.EDITOR:
			enter_editor_mode()
		Editor.instance.InteractionMode.PLAYER:
			enter_player_mode()

## Enter play mode, as though game were running.
func enter_play_mode()->void:
	controls_panel.hide()

## Enter basic editor mode.
func enter_editor_mode()->void:
	controls_panel.show()
	
## Enter player build mode.
func enter_player_mode()->void:
	controls_panel.hide()
	

func set_button_local_space_mode():
	if Editor.instance.current_transform_space_mode == Editor.CurrentTransformSpaceMode.LOCAL:
		button_local_space.button_pressed = true
	else:
		button_local_space.button_pressed = false
		
func _on_button_local_space_toggled(toggled_on: bool) -> void:
	if Editor.instance == null:
		return
	if toggled_on:
		Editor.instance.current_transform_space_mode = Editor.CurrentTransformSpaceMode.LOCAL
	else:
		Editor.instance.current_transform_space_mode = Editor.CurrentTransformSpaceMode.GLOBAL

## Unpacks a prefab if active object is a prefab
func _on_unpack_prefab_button_pressed() -> void:
	Editor.instance.unpack_prefab()
	unpack_prefab_button.hide()
	
func _on_object_selected_changed(_old_object:Node3D, new_object:Node3D)->void:
	if new_object == null:
		return
	selected_object_label.text = new_object.name
	
	if Prefab.is_prefab(new_object):
		unpack_prefab_button.show()
	else:
		unpack_prefab_button.hide()

func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			Editor.instance.current_editor_context = Editor.CurrentEditorContext.OBJECT_EDIT
			PlayerInput.input_mode = PlayerInput.InputMode.OBJECT_EDITOR_INPUT
		1:
			Editor.instance.current_editor_context = Editor.CurrentEditorContext.TERRAIN_EDIT 
			PlayerInput.input_mode = PlayerInput.InputMode.TERRAIN_EDITOR_INPUT
		_:
			PlayerInput.input_mode = PlayerInput.InputMode.CHARACTER_INPUT
	
func _on_editor_context_changed(_old_context:Editor.CurrentEditorContext, new_context:Editor.CurrentEditorContext)->void:
	object_ops.hide()
	object_ops_right.hide()
	match new_context:
		Editor.CurrentEditorContext.OBJECT_EDIT:
			object_ops.show()
			object_ops_right.show()
		Editor.CurrentEditorContext.TERRAIN_EDIT:
			print("terrain_edit")
			pass
