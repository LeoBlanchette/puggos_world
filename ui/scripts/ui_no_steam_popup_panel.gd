extends Control

class_name UINoSteam

static var instance = null

func _ready() -> void:
	if instance == null:
		instance = self
	else:
		queue_free()

	activate(!Global.steam_initialized)

func _exit_tree() -> void:
	if instance == self:
		instance = null

func activate(_show:bool=true):
	if _show:
		show()
	else:
		hide()

func _on_shut_down_button_pressed() -> void:
	GameManager.instance.exit_game()
