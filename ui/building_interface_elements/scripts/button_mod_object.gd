extends Button

class_name ButtonModObject 

var item_id: int = 0
var mod_type: String = ""

func _on_pressed() -> void:
	UIBuildingInterface.toggle_building_interface()
	Cmd.cmd("/placement %s %s"%[mod_type, item_id])
