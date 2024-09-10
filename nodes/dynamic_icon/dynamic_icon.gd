extends Node3D

class_name  DynamicIcon

signal icon_ready(image:ImageTexture)

@export var sub_viewport: SubViewport
@export var anchor: Node3D 
@export var camera_3d: Camera3D 
@export var directional_light_3d: DirectionalLight3D

var icon:ImageTexture = null


var subject:Node3D = null:
	set(node):
		subject = node
		setup_subject(subject)

func set_icon_size(x,y):
	sub_viewport.size = Vector2(x,y)

func setup_subject(ob:Node3D):
	anchor.add_child(ob)
	camera_3d.position = get_camera_position(ob)
	camera_3d.rotation_degrees = get_camera_rotation(ob)
	camera_3d.size = get_camera_orthagonal_size(ob)

func capture():
	await RenderingServer.frame_post_draw
	# Retrieve the captured Image using get_image().
	var image = sub_viewport.get_texture().get_image()
	# Convert Image to ImageTexture.
	icon = ImageTexture.create_from_image(image)
	icon_ready.emit()

func get_camera_orthagonal_size(asset: Node, _default: float = 2.0) -> float:
	var size: float = float(asset.get_meta("icon_camera_orthographic_size", camera_3d.size))
	return size
	
func get_camera_position(asset: Node, _default: Vector3 = Vector3.ZERO) -> Vector3:
	var pos: Vector3 = asset.get_meta("icon_camera_position", camera_3d.position)
	return pos

func get_camera_rotation(asset: Node, _default: Vector3 = Vector3.ZERO) -> Vector3:
	var rot: Vector3 = asset.get_meta("icon_camera_rotation", camera_3d.rotation_degrees)
	return rot
