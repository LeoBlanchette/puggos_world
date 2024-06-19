extends Node

class_name PrefabEditor

var prefab_editor_related_mod_groups: Array[String] = [
	"structures/modular/",
	"materials/structures_modular/"
]

# Called when the node enters the scene tree for the first time.
func _ready():
	
	load_prefab_editor_related_mods()

func load_prefab_editor_related_mods():
	ModManager.mod_manager.load_mods_by_path(prefab_editor_related_mod_groups)

func _on_back_to_world_editor_button_pressed():
	GameManager.change_scene(GameManager.SCENES.WORLD_EDITOR)
