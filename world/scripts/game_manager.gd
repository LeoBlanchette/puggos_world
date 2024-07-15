@icon("res://images/icons/gears.svg")
extends Node

class_name GameManager

signal level_changed(old_level, new_level)

# main level node
@onready var level: Node = $"../Level"

@export var asset_loader: AssetLoader = null

# level path references
@export var menu: String
@export var world: String
@export var world_editor: String
@export var prefab_editor: String  

# main player related
@export var player:Node = null

#level types
enum SCENES {WORLD, WORLD_EDITOR, PREFAB_EDITOR, MENU}
static var current_level = SCENES.MENU

static var instance : GameManager

# Called when the node enters the scene tree for the first time.
func _ready():
		
	if GameManager.instance == null:
		GameManager.instance = self
	else:
		queue_free()
		
	# Start steamworks, first priority.
	Global.initialize_steam()
	
	# Activate the achievements system.
	Achievements.activate()
	print_steam_integrated_welcome_message()
	
	# Activate the network manager....		
	NetworkManager.initialize_network()
	NetworkManager.create_single_player_game()
	
	# Activate the workshop.
	Workshop.activate()
	
	# Do achievement 
	Achievements.achievement.emit("started_game", {})

func _exit_tree() -> void:
	if GameManager.instance == self:
		GameManager.instance = null

#region Level Management

static func change_scene(scene: SCENES):
	
	if scene == SCENES.MENU:
		GameManager.instance.change_to_menu_scene()
		
	if scene == SCENES.WORLD:
		GameManager.instance.change_to_world_scene()
		
	if scene == SCENES.WORLD_EDITOR:
		GameManager.instance.change_to_world_editor_scene() 

	if scene == SCENES.PREFAB_EDITOR:
		GameManager.instance.change_to_prefab_editor_scene() 

func change_to_menu_scene():
	clear_level()
	load_level(menu)
	free_mouse()	
	update_scene_status(current_level, GameManager.SCENES.MENU)
	NetworkManager.create_single_player_game()

func change_to_world_scene():
	clear_level()
	load_level(world)
	lock_mouse()
	update_scene_status(current_level, GameManager.SCENES.WORLD)
	
func change_to_world_editor_scene():
	clear_level()
	load_level(world_editor)
	free_mouse()
	update_scene_status(current_level, GameManager.SCENES.WORLD_EDITOR)


func change_to_prefab_editor_scene():
	clear_level()
	load_level(prefab_editor)
	lock_mouse()
	update_scene_status(current_level, GameManager.SCENES.PREFAB_EDITOR)

func update_scene_status(old_level:GameManager.SCENES, new_level:GameManager.SCENES):
	GameManager.current_level = new_level
	level_changed.emit(old_level, new_level)

func load_level(resource : String):
	var scene: Resource = load(resource)
	var new_instance = scene.instantiate()
	level.add_child(new_instance)
	

func clear_level():
	var children =  level.get_children()
	for child in children:		
		child.queue_free()
		

func exit_game():
	get_tree().quit()

#endregion

func register_player(ob:Node) -> void:
	instance.player = ob
	Players.set_player_character(multiplayer.get_unique_id(), ob)	

static func get_player() -> Node:
	return GameManager.instance.player

# mice 
func lock_mouse():
	if is_mouse_free_scene():
		free_mouse()
		return
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func free_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func hide_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)	

# steam 
func print_steam_integrated_welcome_message():
	print("Welcome to Puggo's World, %s!"%Global.steam_username)

static func get_steam_user_id():
	return instance.steam_user_id
	
static func get_steam_user_name():
	return instance.steam_user_name

# booleans 

func is_mouse_free_scene():
	if GameManager.current_level == GameManager.SCENES.MENU:
		return true

func is_mouse_locked() -> bool:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		return true
	return false

func is_ui_blocking():
	return UI.instance.is_ui_blocking()

func is_steam_running():
	return Steam.isSteamRunning()
	
