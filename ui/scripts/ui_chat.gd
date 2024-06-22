extends Control
class_name  UIChat


const CHAT_MESSAGE = preload("res://ui/chat_interface_elements/chat_message.tscn")

@export var chat_messages_vbox: VBoxContainer
@export var command_input: LineEdit = null 
var text_lines: Array[HBoxContainer] = []

static var instance = null

func _ready() -> void:
	if instance == null:
		instance = self
	else: 
		queue_free()

func _exit_tree():
	if UI.instance == self:
		UI.instance = null

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_released("enter"):		
		var open: bool = toggle_command_input()
		if not open:
			submit_command()
	
func toggle_command_input() -> bool:	
	if command_input.visible:
		print(command_input.visible)
		command_input_close()
		return false
	else:
		command_input_open()
		return true
	

func command_input_open():
	command_input.set_visible(true)
	GameManager.instance.hide_mouse()
	command_input.grab_focus()
	
func command_input_close():	
	command_input.set_visible(false)
	GameManager.instance.lock_mouse()

func submit_command():
	var text = command_input.text.strip_edges()	
	Cmd.cmd(text)
	command_input.clear()

func propogate_messages(peer_id:int, text:String):
	var chat_message = CHAT_MESSAGE.instantiate()
	chat_messages_vbox.add_child(chat_message)
	var steam_id:int = Players.get_player_steam_id_by_peer_id(peer_id)
	chat_message.create_chat_message(steam_id, text)
	text_lines.append(chat_message)
	if text_lines.size() == 5:
		var delete_me:HBoxContainer = text_lines[0]
		delete_me.queue_free()
		text_lines.remove_at(0)
	
	
func activate_based_on_scene(new_level):
	
	if new_level == GameManager.SCENES.MENU:
		turn_off_chat_interface()	
		return
	turn_on_chat_interface()

## deactivates chat interface altogether.
func turn_off_chat_interface():
	set_process_input(false)
	set_visible(false)
	

## activates chat interface.
func turn_on_chat_interface():	
	set_process_input(true)	
	set_visible(true)
	# so that the line input is not visibile at first, only when you push enter.
	command_input_close()
	
func is_chat_open()->bool:
	return command_input.visible

func _on_game_manager_level_changed(_old_level: Variant, new_level: Variant) -> void:
	activate_based_on_scene(new_level)

## this function is called from networm manager as a chat message is sent from a player to all.
func recieve_chat_message_from_server(peer_id:int, message:String):
	propogate_messages(peer_id, message)


func _on_ui_building_interface_building_interface_visible(old_state: Variant, new_state: Variant) -> void:
	if new_state == true:
		# a blocking state exists. Hide chat. 
		turn_off_chat_interface()
	else:
		turn_on_chat_interface()
		
		
