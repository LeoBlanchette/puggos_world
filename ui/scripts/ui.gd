@icon("res://images/icons/treasure-map.svg")
extends Control

class_name UI

## a list of UIs to check. If they are visible they, they get closed with Escape key.
@export var escapable_ui_nodes: Array[Control]

@onready var ui_main: Control = $UIMain
@onready var ui_world: Control = $UIWorld
@onready var ui_world_editor: Control = $UIWorldEditor
@onready var ui_prefab_editor: Control = $UIPrefabEditor
@onready var ui_building_interface: UIBuildingInterface = $UIBuildingInterface
@onready var esc_menu: EscapeMenu = $EscMenu

## when true, other UI nodesv (such as chat/commands) will not accept Enter
static var block_enter:bool = false

static var instance:UI = null

var is_first_entry:bool = true

func _ready():
	if UI.instance == null:
		UI.instance = self
	else:
		queue_free()
	
	if not Global.steam_initialized:
		UINoSteam.instance.activate()
	else:
		UINoSteam.instance.activate(false)
	
	GameManager.instance.level_changed.emit(GameManager.SCENES.MENU, GameManager.SCENES.MENU)
	
	ui_main.set_active(false)
	GameManager.instance.ui_ready.emit()
	
func _exit_tree():
	if UI.instance == self:
		UI.instance = null

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if is_first_entry && event.pressed:
			ui_main.set_active(true)
			is_first_entry = false			
			return
			
		check_esc_menu()

func check_esc_menu():
	if Input.is_action_just_pressed("toggle_esc_menu"):
		if is_ui_blocking():
			close_blocking_ui()
		else:
			EscapeMenu.instance.set_active(true)
			GameManager.instance.free_mouse()

func _on_game_manager_level_changed(old_level: Variant, new_level: Variant) -> void:
	
	UIMain.set_active(false)
	UIWorld.set_active(false)
	UIWorldEditor.set_active(false)
	UIPrefabEditor.set_active(false)
	
	match new_level:
		GameManager.SCENES.MENU:
			UIMain.set_active(true)
		GameManager.SCENES.WORLD:
			UIWorld.set_active(true)
		GameManager.SCENES.WORLD_EDITOR:
			UIWorldEditor.set_active(true)
		GameManager.SCENES.PREFAB_EDITOR:
			UIPrefabEditor.set_active(true)
			
	match old_level: 
		pass

func add_to_blocking_ui(node):
	instance.escapable_ui_nodes.append(node)

func close_blocking_ui():
	for ui_node in escapable_ui_nodes:
		if ui_node == null:
			continue
		ui_node.visible = false
	if not GameManager.current_level == GameManager.SCENES.MENU:
		GameManager.instance.lock_mouse()

func is_ui_blocking()->bool:	
	for ui_node in escapable_ui_nodes:
		if ui_node == null:
			continue
		if ui_node.is_visible():
			return true
	if UIChat.instance.is_chat_open():
		return true
	if UIConsole.instance.is_console_open():
		return true
	return false

static func turn_off_ui_element_after_seconds(seconds:float, ui_element:Node)->void:
	await instance.get_tree().create_timer(seconds).timeout
	ui_element.hide()
	
