extends Node3D

class_name  IconGenerator 

@onready var icon_generator: IconGenerator = $"."
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var icon_area: Node3D = $IconArea
@onready var sub_viewport: SubViewport = $IconArea/SubViewport
@onready var camera_3d: Camera3D = $IconArea/SubViewport/Camera3D
@onready var directional_light_3d: DirectionalLight3D = $IconArea/SubViewport/DirectionalLight3D
@onready var anchor: Node3D = $IconArea/SubViewport/Anchor

func get_icon_directory():
	return AssetLoader.get_mod_folder()+"icons/"

func generate_icon(mod_path: String):
	show_icon_generator(true)
	var original_camera_position: Vector3 = camera_3d.position
	var original_camera_rotation: Vector3 = camera_3d.rotation_degrees

	var signature = AssetLoader.asset_loader.get_mod_name_signature(mod_path, ".")
	
	var asset_resource: Resource = ResourceLoader.load(mod_path)
	var asset: Node = asset_resource.instantiate()
	
	if not asset.has_meta("icon_camera_position"):
		#This is not able to do an icon.
		return
	
	var orthagonal_size: float = get_camera_orthagonal_size(asset)
	var camera_position: Vector3 = get_camera_position(asset, original_camera_position)
	var camera_rotation: Vector3 = get_camera_rotation(asset, original_camera_position)
	
	camera_3d.size = orthagonal_size
	camera_3d.position = camera_position
	camera_3d.rotation_degrees = camera_rotation
	
	anchor.add_child(asset)
	
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	
	await RenderingServer.frame_pre_draw
	await RenderingServer.frame_post_draw
	
	var img = sub_viewport.get_viewport().get_texture().get_image()
		
	img.save_png(get_icon_directory()+signature+".png")
	asset.hide()
	asset.queue_free()
	camera_3d.position = original_camera_position
	camera_3d.rotation = original_camera_rotation
	show_icon_generator(false)
	
	
func show_icon_generator(isvisible:bool):
	if(isvisible):
		icon_generator.show()
		sprite_2d.show()
		icon_area.show()	
		camera_3d.show()
		directional_light_3d.show()
		anchor.show()
	else:
		icon_generator.hide()
		sprite_2d.hide()
		icon_area.hide()		
		camera_3d.hide()
		directional_light_3d.hide()
		anchor.hide()		
	

func get_camera_orthagonal_size(asset: Node, default: float = 2.0) -> float:
	var size: float = float(asset.get_meta("icon_camera_orthographic_size", default))
	return size
	
func get_camera_position(asset: Node, default: Vector3 = Vector3.ZERO) -> Vector3:
	var pos: Vector3 = asset.get_meta("icon_camera_position", default)
	return pos

func get_camera_rotation(asset: Node, default: Vector3 = Vector3.ZERO) -> Vector3:
	var pos: Vector3 = asset.get_meta("icon_camera_rotation", default)
	return pos
