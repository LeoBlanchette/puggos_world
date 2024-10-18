extends Node3D

class_name  TerrainEditor


@export var terrain_3d: Terrain3D 
var editor: Terrain3DEditor
var brush:Dictionary
var camera_3d:Camera3D
var camera_direction: Vector3

var intersection_point:Vector3 
var invalid_intersection_point:bool = true

var mouselook_engaged:bool = false

func _process(delta: float) -> void:
	update_mouse_terrain_intersection_point()
	

func set_brush_data():
	#TEMPORARY"res://addons/terrain_3d/brushes/circle0.exr"
	var brush_img = Image.load_from_file("res://addons/terrain_3d/brushes/circle0.exr")
	print(brush_img)
	brush = { 
		"brush": [brush_img, ImageTexture.create_from_image(brush_img)], 
		"size": 50, 
		"strength": 10, 
		"enable": true, 
		"height": 50.0000081956387, 
		"height_picker": 0, 
		"color": Color.WHITE, 
		"color_picker": 0, 
		"roughness": 0, 
		"roughness_picker": 0, 
		"enable_texture": true, 
		"enable_angle": true, 
		"angle": 0, 
		"angle_picker": 0, 
		"dynamic_angle": false, 
		"enable_scale": true, 
		"scale": 0, 
		"scale_picker": 0, 
		"slope": 0, 
		"gradient_points": [Vector3(0, 0, 0), Vector3(0, 0, 0)], 
		"drawable": false, 
		"height_offset": 0.1, 
		"random_height": 0, 
		"fixed_scale": 100, 
		"random_scale": 20, 
		"fixed_spin": 0, 
		"random_spin": 360, 
		"fixed_angle": 0, 
		"random_angle": 10, 
		"align_to_normal": false, 
		"vertex_color": Color.WHITE, 
		"random_hue": 0, 
		"random_darken": 50, 
		"automatic_regions": true, 
		"align_to_view": true, 
		"show_cursor_while_painting": true, 
		"gamma": 0.99999998137355, 
		"jitter": 50 ,
		}	

func start_operation():
	print(editor.get_operation())
	print(is_terrain_valid(terrain_3d))
	editor.start_operation(intersection_point)
	editor.operate(intersection_point, camera_3d.rotation.y)
	
	
	
func stop_operation():
	editor.stop_operation()
	
func initiate():
	set_process(false)
	
	PlayerInput.mouselook_engaged.connect(_on_engage_mouselook)
	PlayerInput.mouselook_disengaged.connect(_on_disengage_mouselook)
	
	PlayerInput.operation_started.connect(start_operation)
	PlayerInput.operation_stopped.connect(stop_operation)
	
	Editor.instance.changed_editor_context.connect(_on_changed_editor_context)
	
	camera_3d = get_viewport().get_camera_3d()
	terrain_3d = create_terrain()
	editor = Terrain3DEditor.new()
	set_brush_data()
	editor.set_terrain(terrain_3d)
	
	editor.set_tool(Terrain3DEditor.HEIGHT)
	editor.set_operation(Terrain3DEditor.ADD)
	editor.set_brush_data(brush)
	
	# Generate 32-bit noise and import it with scale
	var noise := FastNoiseLite.new()
	noise.frequency = 0.0005
	var img: Image = Image.create(2048, 2048, false, Image.FORMAT_RF)
	for x in 2048:
		for y in 2048:
			img.set_pixel(x, y, Color(noise.get_noise_2d(x, y)*0.5, 0., 0., 1.))
	terrain_3d.storage.import_images([img, null, null], Vector3(-1024, 0, -1024), 0.0, 300.0)

	# Enable collision. Enable the first if you wish to see it with Debug/Visible Collision Shapes
	#terrain.set_show_debug_collision(true)
	terrain_3d.set_collision_enabled(true)
	return
	# Enable runtime navigation baking using the terrain
	$RuntimeNavigationBaker.terrain = terrain_3d
	$RuntimeNavigationBaker.enabled = true
	
	# Retreive 512x512 region blur map showing where the regions are
	var rbmap_rid: RID = terrain_3d.material.get_region_blend_map()
	img = RenderingServer.texture_2d_get(rbmap_rid)
	$UI/TextureRect.texture = ImageTexture.create_from_image(img)

func update_mouse_terrain_intersection_point():
	# Project 2D mouse position to 3D position and direction
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var camera_pos: Vector3 = camera_3d.project_ray_origin(mouse_pos)
	camera_direction = camera_3d.project_ray_normal(mouse_pos)
	
	intersection_point= terrain_3d.get_intersection(camera_pos, camera_direction)
	if intersection_point.z > 3.4e38 or is_nan(intersection_point.z):
		invalid_intersection_point = false
	else:
		invalid_intersection_point = true
		
func create_terrain()->Terrain3D:
	var terrain := Terrain3D.new()
	terrain.set_collision_enabled(false)
	terrain.storage = Terrain3DStorage.new()
	terrain.assets = Terrain3DAssets.new()
	terrain.name = "Terrain3D"
	add_child(terrain, true)
	terrain.material.world_background = Terrain3DMaterial.NONE
	return terrain

func _on_changed_editor_context(old_context:Editor.CurrentEditorContext, new_context:Editor.CurrentEditorContext):
	if new_context == Editor.CurrentEditorContext.TERRAIN_EDIT:
		set_process(true)
	else:
		set_process(false)

func _on_engage_mouselook():
	mouselook_engaged = true
	
func _on_disengage_mouselook():
	mouselook_engaged = false

## TAKEN FROM OFFICIAL editor.gd
func is_terrain_valid(p_terrain: Terrain3D = null) -> bool:
	var t: Terrain3D
	if p_terrain:
		t = p_terrain
	else:
		t = terrain_3d
	if is_instance_valid(t) and t.is_inside_tree() and t.get_storage():
		return true
	return false
