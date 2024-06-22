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

const create_new_character_id = 76767676

var currently_editing_character_id:int = 0

static var instance

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

func add_character(character_name:String, character_id:int):	
	choose_character_option_button.add_item(character_name, character_id)

func set_current_character_selection():
	var selectable_id:int = get_selectable_index_by_character_id(Characters.get_currently_selected_character_id())
	
	choose_character_option_button.select(selectable_id) 
	
func get_selectable_index_by_character_id(character_id:int)->int:
	for x in choose_character_option_button.item_count:
		var character_id_at_index:int = choose_character_option_button.get_item_id(x)
		if character_id_at_index == Characters.get_currently_selected_character_id():
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

func save_from_character_edit()->void:
	var character_template:Dictionary = Characters.new_character()
	character_template["id"] = currently_editing_character_id
	character_template["name"] = character_name_line_edit.text	
	Characters.save_character(character_template)
	
func update_character_edit_panel(character:Dictionary):
	character_name_line_edit.text = character["name"]
	

func go_to_character_manage():
	character_edit_container.hide()
	character_manage_container.show()
	load_character_selection()

func _on_back_button_pressed() -> void:
	save_from_character_edit()
	go_to_character_manage()

func _on_edit_character_button_pressed() -> void:	
	go_to_character_edit(choose_character_option_button.get_selected_id())

func _on_choose_character_option_button_item_selected(index: int) -> void:
	var selected:int = choose_character_option_button.get_selected_id()
	if selected == create_new_character_id:
		go_to_character_edit(choose_character_option_button.get_selected_id())
	else:
		Characters.set_currently_selected_character_id(selected)
		
func _on_delete_button_pressed() -> void:
	var to_delete = currently_editing_character_id
	Characters.delete_character_by_id(to_delete)
	currently_editing_character_id = 0
	go_to_character_manage()
