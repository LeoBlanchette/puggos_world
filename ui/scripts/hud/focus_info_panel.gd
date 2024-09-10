extends PanelContainer

@export var uihud: Control


@onready var interaction_label: Label = $MarginContainer/InteractionLabel
@export var floating_offset:Vector2
var offset:Vector2 = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return
	establish_offset()
	update_interaction_label()
	

func establish_offset():
	offset = Vector2(size.x / 2, 0)

func update_interaction_label():
	if not InteractionNode.instance.is_focused():
		display(false)
		return
	var focused_object:Node3D = InteractionNode.instance.get_focused_object() 
	if focused_object == null:
		display(false)
		return
	var meta_name:String = InteractionNode.instance.get_meta_name()
	if meta_name.is_empty():
		display(false)
		return
	display(true)
	interaction_label.text = meta_name
	position_info_panel()
	
func position_info_panel():	
	var camera_3d:Camera3D = uihud.get_player_camera()
	if camera_3d == null:
		display(false)
		return
	var focused_object:Node3D = InteractionNode.instance.get_focused_object() 
	
	var final_position:Vector2 = Vector2.ZERO
	var initial_ui_position:Vector2 = Vector2.ZERO
	
	var mod_type:String = focused_object.get_meta("mod_type", "")
	
	match mod_type:
		"items":
			initial_ui_position = camera_3d.unproject_position(InteractionNode.instance.get_focused_object_position())
			final_position = initial_ui_position - offset
		"structures":
			var view_area:Vector2 = get_viewport_rect().size
			final_position = Vector2(view_area.x/2, view_area.y-size.y) - size/2
	
	position = final_position

func display(_visible = false):
	if _visible:
		show()
	else:
		hide()
