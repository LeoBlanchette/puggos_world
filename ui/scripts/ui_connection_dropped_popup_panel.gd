extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NetworkManager.connection_dropped_notification.connect(notify_connection_dropped)
	hide()
	
func notify_connection_dropped():
	show()


func _on_button_pressed() -> void:
	hide()
