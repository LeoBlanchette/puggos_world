extends Button

class_name ButtonModObject 

var item_id: int = 0
var scene_path: String = ""

func _on_pressed() -> void:
	UIBuildingInterface.toggle_building_interface()
	var mh = AssetLoader.asset_loader.get_mod_hierarchy(scene_path)
	Cmd.cmd("/placement %s %s"%[mh["mod_type"], item_id])
