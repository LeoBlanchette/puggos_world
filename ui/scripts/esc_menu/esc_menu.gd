extends Control

class_name EscapeMenu 

signal escape_menu_visible(old_value:bool, new_value:bool)

@export var button_main_menu: Button = null
@export var button_world: Button = null
@export var button_world_editor: Button = null
@export var button_prefab_editor: Button = null
@export var button_exit_game: Button = null

static var instance: EscapeMenu = null

func _ready():
	if instance == null:
		instance = self
	else:
		queue_free()

func _exit_tree():
	if instance == self:
		instance = null

func _on_button_main_menu_pressed() -> void:
	GameManager.change_scene(GameManager.SCENES.MENU)


func _on_button_world_pressed() -> void:
	GameManager.change_scene(GameManager.SCENES.WORLD)


func _on_button_world_editor_pressed() -> void:
	GameManager.change_scene(GameManager.SCENES.WORLD_EDITOR)


func _on_button_prefab_editor_pressed() -> void:
	GameManager.change_scene(GameManager.SCENES.PREFAB_EDITOR)

func _on_button_exit_game_pressed() -> void:
	GameManager.instance.exit_game()

func set_active(active:bool):
	if active:
		set_visible(true)
		escape_menu_visible.emit(true, false)
	else:
		set_visible(false)
		escape_menu_visible.emit(false, true)


func _on_game_manager_level_changed(old_level: Variant, new_level: Variant) -> void:
	button_main_menu.show()
	button_world.show()
	button_world_editor.show()
	button_prefab_editor.show()
	button_exit_game.show()
	match new_level:
		GameManager.SCENES.MENU:
			button_main_menu.hide()
			button_prefab_editor.hide()	
		GameManager.SCENES.WORLD:
			button_world.hide()
			button_prefab_editor.hide()
			button_world_editor.hide()
		GameManager.SCENES.WORLD_EDITOR:
			button_world_editor.hide()
			button_world.hide()
			button_exit_game.hide()
		GameManager.SCENES.PREFAB_EDITOR:
			button_prefab_editor.hide()
			button_world.hide()
			button_exit_game.hide()
	
	match old_level:
		pass
	set_active(false)
	
