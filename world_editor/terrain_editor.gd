extends Node3D

class_name  TerrainEditor

@export var terrain_3d: Terrain3D 
var camera_3d:Camera3D
var intersection_point:Vector3 

var mouselook_engaged:bool = false

func _process(delta: float) -> void:
	update_mouse_terrain_intersection_point()
	print(intersection_point)

	
func initiate():
	set_process(false)
	
	PlayerInput.mouselook_engaged.connect(_on_engage_mouselook)
	PlayerInput.mouselook_disengaged.connect(_on_disengage_mouselook)
	Editor.instance.changed_editor_context.connect(_on_changed_editor_context)
	
	camera_3d = get_viewport().get_camera_3d()
	terrain_3d = create_terrain()

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
	var camera_dir: Vector3 = camera_3d.project_ray_normal(mouse_pos)
	
	intersection_point= terrain_3d.get_intersection(camera_pos, camera_dir)

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
