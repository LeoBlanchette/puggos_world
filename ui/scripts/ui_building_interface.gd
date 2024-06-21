extends Control

class_name UIBuildingInterface

signal building_interface_visible(old_state, new_state)

static var instance: UIBuildingInterface = null
@onready var grid_container: GridContainer = $GridContainer

const ICONS_FOLDER:String = "res://mods/icons/"
const BUTTON_MOD_OBJECT:Resource = preload("res://ui/building_interface_elements/button_mod_object.tscn")

func _ready():
	if instance == null:
		instance = self
	else:
		queue_free()

func _exit_tree():
	if instance == self:
		instance = null

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("toggle_crafting_menu"):
			toggle_building_interface()

static func set_active(active:bool):
	if active:
		UIBuildingInterface.instance.show() 
		GameManager.instance.free_mouse()		
	else:
		UIBuildingInterface.instance.hide() 
		GameManager.instance.lock_mouse()

static func toggle_building_interface():	
	if GameManager.current_level == GameManager.SCENES.MENU:
		UIBuildingInterface.instance.hide()
		GameManager.instance.lock_mouse()
		return
		
	if UIBuildingInterface.instance.is_visible():
		UIBuildingInterface.instance.hide()
		GameManager.instance.lock_mouse()
	else:
		UIBuildingInterface.instance.show() 
		GameManager.instance.free_mouse()
		
		#temporary test
		instance.clear_grid_container()
		var results:Dictionary = query_index({"query": "structures"})
		instance.populate_building_interface_grid(results)
		
	instance.building_interface_visible.emit(!instance.visible, instance.visible)
	
static func query_index(category:Dictionary)->Dictionary:
	var results:Dictionary = ObjectIndex.query(category)
	return results
	
func populate_building_interface_grid(results:Dictionary):
	for key in results:
		var id:int = key
		var ob:Node = results[key]
		instance.create_button_mod_object(ob, id)
		var button:Node = instance.create_button_mod_object(ob, id)
		instance.add_button_to_grid_container(button)
		
func create_button_mod_object(ob:Node, id:int) -> Node:
	var mod_path:String = ob.get_meta("mod_path") 
	var signature: String = AssetLoader.asset_loader.get_mod_name_signature(mod_path, ".")
	var icon_img_file:String = "%s%s.png"%[ICONS_FOLDER, signature]
	
	var button:Button = BUTTON_MOD_OBJECT.instantiate()
	button.icon = load(icon_img_file) 
	
	button.item_id = id
	button.scene_path = mod_path
	return button

func add_button_to_grid_container(button:Node)->void:
	grid_container.add_child(button)

func clear_grid_container():
	var children:Array = grid_container.get_children()
	for child:Node in children:
		child.queue_free()
