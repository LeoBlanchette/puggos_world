extends VBoxContainer

@onready var host_join_label: Label = $HostJoinLabel
@onready var ip_address_note_label: Label = $IPAddressNoteLabel

@onready var ip_address_line_edit: LineEdit = $IPAddressLineEdit
@onready var port_line_edit: LineEdit = $PortLineEdit


@onready var direct_join_button: Button = $DirectJoinButton
@onready var direct_host_button: Button = $DirectHostButton

var last_manual_ip_address = ""

func _ready() -> void:
	set_to_join()

func join_game_direct():	
	NetworkManager.join_game(ip_address_line_edit.text, port_line_edit.text)
	UIMain.display_status("Connecting to server: %s:%s ..."%[ip_address_line_edit.text, port_line_edit.text])
	UI.turn_off_ui_element_after_seconds(5, UIMain.instance.status_panel)
		
func host_game_direct():	
	NetworkManager.create_game(port_line_edit.text)
	UIMain.display_status("Hosting game on port: %s"%[port_line_edit.text])
	UI.turn_off_ui_element_after_seconds(3, UIMain.instance.status_panel) 
	GameManager.change_scene(GameManager.SCENES.WORLD)

func _on_direct_join_button_pressed() -> void:
	join_game_direct()


func _on_direct_host_button_pressed() -> void:
	host_game_direct()

func set_to_join():
	host_join_label.text = "Direct Connection [Join]"
	ip_address_note_label.text = "IP Address:"
	ip_address_line_edit.text = last_manual_ip_address
	ip_address_line_edit.editable = true
	direct_join_button.set_visible(true)
	direct_host_button.set_visible(false)
	
	
func set_to_host():
	last_manual_ip_address = ip_address_line_edit.text
	host_join_label.text = "Direct Connection [Host]"
	ip_address_note_label.text = "Host IP Address:"
	direct_join_button.set_visible(false)
	direct_host_button.set_visible(true)
	var ip = NetworkManager.get_machines_ip_address()	
	ip_address_line_edit.text = ip
	ip_address_line_edit.editable = false

	

func _on_join_host_check_button_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		set_to_join()
	else:
		set_to_host()
