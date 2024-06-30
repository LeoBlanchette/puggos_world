extends Node

func apply_default_groups(ob:Node)->void:
	
	var mod_path:String = ob.scene_file_path

	if mod_path.is_empty():
		return
	var mod_hierarchy:Dictionary = AssetLoader.asset_loader.get_mod_hierarchy(mod_path)

	
	#ASSIGN
	var mod_creator:String = "creator_%s"%mod_hierarchy["creator"]
	var mod_project:String = "project_%s"%mod_hierarchy["project"]
	var mod_type:String = mod_hierarchy["mod_type"]
	var mod_type_category:String = mod_hierarchy["mod_type_category"]
	var mod_name:String = mod_hierarchy["mod_name"]

	#APPLY
	ob.add_to_group(mod_creator)
	ob.add_to_group(mod_project)
	ob.add_to_group(mod_type)
	ob.add_to_group(mod_type_category)
	ob.add_to_group(mod_name)
	apply_save_groups(ob)
	
func apply_save_groups(ob:Node):
	match GameManager.current_level:
		GameManager.SCENES.WORLD:
			pass
		GameManager.SCENES.PREFAB_EDITOR:
			ob.add_to_group("prefab_member")
		GameManager.SCENES.WORLD_EDITOR:
			pass	
	
