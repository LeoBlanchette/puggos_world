extends Control

@export var kick_notice:RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NetworkManager.connection_dropped_notification.connect(notify_connection_dropped)
	NetworkManager.kick_notification.connect(show_kick_notification)
	kick_notice.hide()
	hide()
	
func notify_connection_dropped():
	show()

func show_kick_notification(text:String):
	kick_notice.show()
	kick_notice.text = text

func _on_button_pressed() -> void:
	hide()
	kick_notice.hide()
