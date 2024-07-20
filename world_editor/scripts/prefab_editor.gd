extends WorldSystems

class_name PrefabEditor

var prefab_editor_related_mod_groups: Array[String] = [
	"structures/modular/",
	"materials/structures_modular/",
	"items/junk/"
]

static var instance:PrefabEditor = null

var prefab_name = ""

# Called when the node enters the scene tree for the first time.
func _ready():	
	if PrefabEditor.instance == null:
		PrefabEditor.instance = self
	else:
		PrefabEditor.instance.queue_free()
		
	ObjectIndex.object_index.spawned.connect(_on_object_spawned)
	load_prefab_editor_related_mods()
	Achievements.achievement.emit("prefab_editor")

func _exit_tree() -> void:
	if PrefabEditor.instance == self:
		PrefabEditor.instance = null

func load_prefab_editor_related_mods():
	ModManager.mod_manager.load_mods_by_path(prefab_editor_related_mod_groups)

func _on_back_to_world_editor_button_pressed():
	GameManager.change_scene(GameManager.SCENES.WORLD_EDITOR)

func load_prefab(meta:={}, commands:=[])->void:
	if meta.has("name"):
		prefab_name = meta["name"]
	for command in commands:
		Cmd.cmd(command)

func _on_object_spawned(ob:Node):
	ObjectGrouper.apply_default_groups(ob)
