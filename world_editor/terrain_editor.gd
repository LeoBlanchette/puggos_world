extends Node3D

class_name  TerrainEditor

@export var terrain: Terrain3D

var editor:Terrain3DEditor = null
var camera_pos: Vector3 
var camera_dir: Vector3 
var cam:Camera3D

func _enter_tree() -> void:
	editor = Terrain3DEditor.new()

func _physics_process(delta: float) -> void:
	if EditorInteractor.instance == null:
		return
	if Editor.instance == null:
		return
	if Editor.instance.current_editor_context != Editor.CurrentEditorContext.TERRAIN_EDIT:
		return
		
	editor.set_terrain(terrain)
		
	cam = get_viewport().get_camera_3d()
	terrain.set_camera(cam)
	
	var mouse_pos = get_viewport().get_mouse_position()
	camera_pos = cam.project_ray_origin(mouse_pos)
	camera_dir = cam.project_ray_normal(mouse_pos)
	
	var intersection_point: Vector3 = terrain.get_intersection(camera_pos, camera_dir)
	if intersection_point.z > 3.4e38 or is_nan(intersection_point.z): # max double or nan
		return
	print(intersection_point)
