extends Control

class_name CharacterOptions

# Character Edit
@export var character_edit_container: MarginContainer
@export var character_name_line_edit: LineEdit
@export var delete_button: Button
@export var back_button: Button

# Character Management
@export var character_manage_container: MarginContainer
@export var choose_character_option_button: OptionButton
@export var edit_character_button: Button 
@export var personality_option_button: OptionButton 

const create_new_character_id = 76767676

var currently_editing_character_id:int = 0
var player:Player = null

# Container
@export var character_customizer_buttons: VBoxContainer
@export var character_items_scroll_container: CharacterItemsUI 


static var instance:CharacterOptions

func _ready():
	if instance == null:
		instance = self
	else:
		queue_free()
	go_to_character_manage()
	load_character_selection()

func _exit_tree():
	if instance == self:
		instance = null

func load_character_selection():	
	choose_character_option_button.clear()
	for character in Characters.get_characters():
		add_character(character["name"], character["id"])
		#add_character(character["name"], character["id"])	
	set_current_character_selection()
	add_new_character_option()
	Characters.load_current_character_appearance()

func add_character(character_name:String, character_id:int):	
	choose_character_option_button.add_item(character_name, character_id)

func set_current_character_selection():
	var selectable_id:int = get_selectable_index_by_character_id(Characters.get_currently_selected_character_id())
	
	choose_character_option_button.select(selectable_id) 
	
func get_selectable_index_by_character_id(character_id:int)->int:
	for x in choose_character_option_button.item_count:
		var character_id_at_index:int = choose_character_option_button.get_item_id(x)
		if character_id_at_index == character_id:
			return x
	return 0

func add_new_character_option():
	choose_character_option_button.add_separator()
	choose_character_option_button.add_item("* New Character", create_new_character_id)

func go_to_character_edit(character_id)->void:
	
	var character = Characters.get_characters()[0]
	currently_editing_character_id = character_id
	
	if character_id == create_new_character_id:
		character = Characters.new_character("N00B")
		currently_editing_character_id = character["id"]	
	else:
		character = Characters.get_character_by_id(currently_editing_character_id)
	
	character_edit_container.show()
	character_manage_container.hide()
	update_character_edit_panel(character)

## The save function for a character template.
func save_from_character_edit()->void:
	var character_template:Dictionary = Characters.new_character()
	character_template["id"] = currently_editing_character_id
	character_template["name"] = character_name_line_edit.text	
	character_template["personality"] = personality_option_button.get_item_id(personality_option_button.selected)
	var equipped:Dictionary = Cmd.list_equipped()
	# Adds all items equipped to the template.
	for key in equipped:
		var id:int = equipped[key]
		character_template[key]=id
	Characters.set_currently_selected_character_id(currently_editing_character_id)
	Characters.save_character(character_template)
	Achievements.achievement.emit("created_character")
	
func update_character_edit_panel(character:Dictionary):
	character_name_line_edit.text = character["name"]	
	
	# Select the appropriate personality option 
	if character.has("personality"):
		for idx in range(0, personality_option_button.item_count):
			var personality_id = personality_option_button.get_item_id(idx)
			if personality_id != character["personality"]:
				continue
			personality_option_button.selected = idx

func go_to_character_manage():
	character_edit_container.hide()
	character_manage_container.show()
	load_character_selection()

func _on_back_button_pressed() -> void:
	save_from_character_edit()
	go_to_character_manage()
	

func _on_edit_character_button_pressed() -> void:	
	go_to_character_edit(choose_character_option_button.get_selected_id())

func _on_choose_character_option_button_item_selected(_index: int) -> void:
	var selected:int = choose_character_option_button.get_selected_id()
	if selected == create_new_character_id:
		go_to_character_edit(choose_character_option_button.get_selected_id())
	else:
		Characters.set_currently_selected_character_id(selected)
		Characters.load_current_character_appearance()
		
func _on_delete_button_pressed() -> void:
	var to_delete = currently_editing_character_id
	Characters.delete_character_by_id(to_delete)
	currently_editing_character_id = 0
	go_to_character_manage()

## Populates the main character options involving animations and appearance.
func populate_character_options():

	for child in character_customizer_buttons.get_children():
		child.queue_free()
	var appearance:CharacterAppearance = player.avatar.character_appearance
	var keys = appearance.Equippable.keys()
	for key in keys:
		var description:String = appearance.get_slot_description(appearance.Equippable.get(key))
		make_character_slot_button(key, description)
	if ObjectIndex.index.has("animations"):
		for key in ObjectIndex.index["animations"]:
			var animation:Node = ObjectIndex.index["animations"][key]
			if animation.has_meta("personality"):
				add_personality_option(animation)

func add_personality_option(animation:Node):
	var animation_name:String = animation.get_meta("name", "Personality")
	var id:int = animation.get_meta("id")
	personality_option_button.add_item(animation_name, id)

func make_character_slot_button(slot:String, description:String):
	var button:Button = Button.new()
	button.text = description
	
	button.connect("pressed", character_items_scroll_container.open.bind(slot, description))
	character_customizer_buttons.add_child(button)

func _on_personality_option_button_item_selected(index: int) -> void:
	var id:int = personality_option_button.get_item_id(index)
	Cmd.cmd("/set_personality %s"%str(id))
