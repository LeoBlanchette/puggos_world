extends LineEdit


var value : float = 0.0 # export as needed
var previous_valid_value:float 

func _ready() -> void:
	text_submitted.connect(_on_line_edit_text_changed)
	focus_entered.connect(block_enter)
	gui_input.connect(release_enter)

func _on_line_edit_text_changed(new_text: String) -> void: # "text_changed" signal handler
	if new_text.is_empty():
		self.text = str(previous_valid_value)
		return
	if new_text.is_valid_float():
		value = float(new_text)
		previous_valid_value = value
		
	else: # optional rollback to last good one
		self.text = str(previous_valid_value)
	deselect()
	
	
func block_enter():
	UI.instance.block_enter = true
	
func release_enter(event:InputEvent):
	if event.is_action_released("enter"):
		accept_event()
		release_focus()
		UI.instance.block_enter = false
		
	
