extends Control

class_name UIConsole

static var instance:UIConsole = null
const CONSOLE_TEXT = preload("res://ui/console_interface_elements/console_text.tscn")
@onready var v_box_container: VBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer
@onready var scroll_container: ScrollContainer = $MarginContainer/ScrollContainer
@onready var scrollbar = $MarginContainer/ScrollContainer.get_v_scroll_bar()
@onready var command_input: LineEdit = $Input/LineEdit

var unilink_shown:bool =false

func _ready() -> void:
	if instance == null:
		instance = self
	else: 
		queue_free()
	visible = false
	
	
func _input(event: InputEvent) -> void:
	if UIChat.instance.is_chat_open():
		return
	if event.is_action_pressed("open_console"):
		toggle_console()
	if event.is_action_pressed("enter"):		
		submit_command()
		accept_event()
	
	if event.is_action_pressed("ui_up"):
		scroll_input_history("UP")
	if event.is_action_pressed("ui_down"):
		scroll_input_history("DOWN")

func _exit_tree():
	if UI.instance == self:
		UI.instance = null

func toggle_console():
	visible = !visible
	

func print_to_console(text:String):	
	var console_txt = CONSOLE_TEXT.instantiate()
	v_box_container.add_child(console_txt)
	console_txt.parse_bbcode(text)
	scroll_to_end()

func scroll_to_end():	
	scroll_container.scroll_vertical = scrollbar.max_value

func log_chat_to_console(peer_id:int, text:String):	
	text = HelperFunctions.remove_bb_code(text)
	var current_time = Time.get_datetime_string_from_system (false, true)
	var player:Dictionary = Players.get_player(peer_id)
	if player == null: 
		return
	text = "[%s] %s"%[current_time, text]	
	print_to_console(text)

func is_console_open():
	return visible

func _on_visibility_changed() -> void:
	if GameManager.instance == null:
		#Not ready yet.
		return 
	if visible:
		command_input.clear()
		GameManager.instance.free_mouse()
		command_input.set_process_input(true)
		command_input.grab_focus()
		show_unilink_message()
		scroll_to_end()
	else:
		GameManager.instance.lock_mouse()
		command_input.set_process_input(false)

func show_unilink_message():
	if !unilink_shown:
		Cmd.cmd("/unilink_info")
		unilink_shown = true

func submit_command():
	var text:String = command_input.text.strip_edges()	
	Cmd.cmd(text)
	command_input.clear()	
	#check achievement
	Achievements.do_text_achievement(text)
	command_input.grab_focus()
	scroll_to_end()

func clear():
	for child in v_box_container.get_children():
		child.queue_free()

func _on_line_edit_text_changed(new_text: String) -> void:
	# Stops the tilde key from registering into the input when the 
	# interface is just opened
	if new_text.strip_edges() == "`":
		command_input.clear()

func scroll_input_history(action:String):
	if not is_console_open():
		return
	if action=="UP":
		populate_input_text(Cmd.get_cmd_history_back())
	if action == "DOWN":
		populate_input_text(Cmd.get_cmd_history_forward())

func populate_input_text(text:String)->void:
	command_input.text = text

func _on_v_box_container_resized() -> void:
	scroll_to_end()
