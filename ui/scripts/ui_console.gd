extends Control

class_name UIConsole

static var instance = null
const CONSOLE_TEXT = preload("res://ui/console_interface_elements/console_text.tscn")
@onready var v_box_container: VBoxContainer = $MarginContainer/VBoxContainer

func _ready() -> void:
	if instance == null:
		instance = self
	else: 
		queue_free()
	visible = false
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("open_console"):
		toggle_console()
		

func _exit_tree():
	if UI.instance == self:
		UI.instance = null

func toggle_console():
	visible = !visible
	

func print_to_console(text:String):	
	var console_txt = CONSOLE_TEXT.instantiate()
	v_box_container.add_child(console_txt)
	console_txt.add_text(text)
