extends Control

class_name UIMain

@export var play_options: VBoxContainer
@export var characters_options: VBoxContainer
@export var world_editor_options: VBoxContainer
@export var mod_options: VBoxContainer
@export var configs_options: VBoxContainer
@export var direct_connection_options: VBoxContainer

@export var status_panel: Panel
@export var status_label: Label

static var instance:UIMain = null
const SCENE_TYPE:GameManager.SCENES = GameManager.SCENES.MENU

func _ready():
	if instance == null:
		instance = self
	else:
		queue_free()
	close_all_subwindows()


func _exit_tree():
	if instance == self:
		instance = null

static func get_scene_type():
	return UIMain.instance.SCENE_TYPE

static func set_active(active:bool):
	if active:
		instance.show()
	else:
		instance.hide()

func open_play_options():
	close_all_subwindows()
	play_options.show()

func open_characters_options():
	close_all_subwindows()
	characters_options.show()

func open_editor_options():
	close_all_subwindows()
	world_editor_options.show()

func open_mods_options():
	close_all_subwindows()
	mod_options.show()
	
func open_configs_options():
	close_all_subwindows()
	configs_options.show()

func open_direct_connection_options():
	close_all_subwindows()
	direct_connection_options.show()

func _on_button_play_open_menu_pressed() -> void:
	open_play_options()

func _on_button_characters_pressed() -> void:
	open_characters_options()

func _on_button_editor_pressed() -> void:
	open_editor_options()

func _on_button_mods_pressed() -> void:
	open_mods_options()
	

func _on_button_configs_pressed() -> void:
	open_configs_options()

func _on_direct_connect_pressed() -> void:
	open_direct_connection_options()

func _on_direct_connection_back_pressed() -> void:
	open_play_options()

func close_all_subwindows():
	play_options.hide()
	characters_options.hide()
	world_editor_options.hide()
	mod_options.hide()
	configs_options.hide()
	direct_connection_options.hide()
	hide_status_panel()

func is_a_subwindow_open()->bool:
	if play_options.is_visible():
		return true
	if characters_options.is_visible():
		return true
	if world_editor_options.is_visible():
		return true
	if mod_options.is_visible():
		return true
	if configs_options.is_visible():
		return true
	if direct_connection_options.is_visible():
		return true	

	return false

func show_status_panel():
	status_panel.show()

func hide_status_panel():
	status_panel.hide()

static func display_status(status:String):
	if instance == null:
		return
	instance.show_status_panel()
	instance.status_label.text = status

func _on_button_exit_main_pressed() -> void:
	GameManager.instance.exit_game()
