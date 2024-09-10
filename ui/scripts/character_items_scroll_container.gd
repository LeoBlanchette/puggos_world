extends ScrollContainer

class_name CharacterItemsUI

@onready var character_items_grid_container: GridContainer = $CharacterItemsGridContainer

func _ready() -> void:
	hide()

func open(slot:String, _slot_description:String):
	var slot_number:int = CharacterAppearance.Equippable.get(slot)
	
	show()
	add_unequip_button(slot_number)
	if ObjectIndex.index.has("items"):
		for key in ObjectIndex.index["items"]:
			var ob:Node3D = ObjectIndex.index["items"][key]
			if not ob.has_meta("equippable_slot"):
				continue			
			if ob.get_meta("equippable_slot", 0) != slot_number:
				continue
			attempt_to_add_option(ob)

func add_unequip_button(slot:int):
	# Now that icon is prepared, add the button.
	var button = Button.new()

	button.tooltip_text = "Remove Item"
	#button.text = ob.get_meta("name", "Item")
	button.connect("pressed", run_unequip_command.bind(slot))
	character_items_grid_container.add_child(button)

func attempt_to_add_option(ob:Node):
	var id:int = ob.get_meta("id", 0)
	var mod_type:String = ob.get_meta("mod_type", "items")
	var icon:DynamicIcon = await ObjectIndex.object_index.get_icon(mod_type, id, 128, 128)
	
	# Now that icon is prepared, add the button.
	var button = Button.new()
	button.icon = icon.icon
	button.tooltip_text = ob.get_meta("name", "Item")
	#button.text = ob.get_meta("name", "Item")
	button.connect("pressed", run_equip_command.bind(id))
	character_items_grid_container.add_child(button)

func run_equip_command(id:int):
	var command:String = "/equip %s"%str(id)
	Cmd.cmd(command)
	hide()

func run_unequip_command(slot:int):
	var command:String = "/unequip %s"%str(slot)
	Cmd.cmd(command)
	hide()

func _on_hidden() -> void:
	for child in character_items_grid_container.get_children():
		child.queue_free()
