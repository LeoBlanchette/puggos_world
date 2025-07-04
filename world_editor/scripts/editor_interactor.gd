class_name EditorInteractor extends Node3D

## https://github.com/adamviola/simple-free-look-camera/blob/master/camera.gd

signal entered_viewport(in_viewport:bool)
signal object_selected(ob:Node3D)

# Modifier keys' speed multiplier
const SHIFT_MULTIPLIER = 2.5
const ALT_MULTIPLIER = 1.0 / SHIFT_MULTIPLIER
const RAY_LENGTH = 1000

@export_range(0.0, 1.0) var sensitivity: float = 0.25

# Mouse state
var _total_pitch = 0.0

# Movement state
var _direction = Vector3(0.0, 0.0, 0.0)
var _velocity = Vector3(0.0, 0.0, 0.0)
var _acceleration = 30
var _deceleration = -10

#targeting
#{
   #position: Vector2 # point in world space for collision
   #normal: Vector2 # normal in world space for collision
   #collider: Object # Object collided or null (if unassociated)
   #collider_id: ObjectID # Object it collided against
   #rid: RID # RID it collided against
   #shape: int # shape index of collider
   #metadata: Variant() # metadata of collider
#}

var target_result:Dictionary = {}
var selected_object:Node3D = null

var viewport_interaction:bool = false

static var instance:EditorInteractor = null

func _ready() -> void:
	if instance == null:
		instance = self
	else:
		queue_free()
		
	entered_viewport.connect(_on_entered_viewport)
	object_selected.connect(_on_object_selected)
	Editor.instance.connect_editor_interactor()
	PlayerInput.editor_target_selected.connect(select_target)

func _exit_tree() -> void:
	if instance == self:
		instance = null
	#entered_viewport.disconnect(_on_entered_viewport)
	#object_selected.disconnect(UIWorldEditor.instance._on_object_selected)

func _physics_process(_delta: float) -> void:
	if UI.instance.is_ui_blocking():
		return
	get_current_target()

# Updates mouselook and movement every frame
func _process(delta):
	if UI.instance.is_ui_blocking():
		return
	_update_mouselook()
	_update_movement(delta)

# Updates camera movement
func _update_movement(delta):
	# Computes desired direction from key states
	_direction = Vector3(
		(PlayerInput.editor_right_pressed as float) - (PlayerInput.editor_left_pressed as float), 
		(PlayerInput.editor_down_pressed as float) - (PlayerInput.editor_up_pressed as float),
		(PlayerInput.editor_backward_pressed as float) - (PlayerInput.editor_forward_pressed as float)
	)
	
	# Computes the change in velocity due to desired direction and "drag"
	# The "drag" is a constant acceleration on the camera to bring it's velocity to 0
	var offset = _direction.normalized() * _acceleration * PlayerInput._vel_multiplier * delta \
		+ _velocity.normalized() * _deceleration * PlayerInput._vel_multiplier * delta
	
	# Compute modifiers' speed multiplier
	var speed_multi = 1
	if PlayerInput.editor_shift_pressed: speed_multi *= SHIFT_MULTIPLIER
	if PlayerInput.editor_alt_pressed: speed_multi *= ALT_MULTIPLIER
	
	# Checks if we should bother translating the camera
	if _direction == Vector3.ZERO and offset.length_squared() > _velocity.length_squared():
		# Sets the velocity to 0 to prevent jittering due to imperfect deceleration
		_velocity = Vector3.ZERO
	else:
		# Clamps speed to stay within maximum value (_vel_multiplier)
		_velocity.x = clamp(_velocity.x + offset.x, -PlayerInput._vel_multiplier, PlayerInput._vel_multiplier)
		_velocity.y = clamp(_velocity.y + offset.y, -PlayerInput._vel_multiplier, PlayerInput._vel_multiplier)
		_velocity.z = clamp(_velocity.z + offset.z, -PlayerInput._vel_multiplier, PlayerInput._vel_multiplier)
	
		translate(_velocity * delta * speed_multi)

# Updates mouse look 
func _update_mouselook():
	# Only rotates mouse if the mouse is captured
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		PlayerInput._mouse_position *= sensitivity
		var yaw = PlayerInput._mouse_position.x
		var pitch = PlayerInput._mouse_position.y
		PlayerInput._mouse_position = Vector2(0, 0)
		
		# Prevents looking up/down too far
		pitch = clamp(pitch, -90 - _total_pitch, 90 - _total_pitch)
		_total_pitch += pitch
	
		rotate_y(deg_to_rad(-yaw))
		rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))

func get_current_target():
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		return 
	var space_state = get_world_3d().direct_space_state
	var cam:Camera3D = $Camera3D
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	target_result = space_state.intersect_ray(query)


func select_target():
	if target_result.is_empty():
		Editor.instance.clear_active_object()
		if EditorGizmo.instance != null:
			EditorGizmo.instance.set_gizmo_to_clicked_space()
		return
	selected_object = target_result["collider"]
	object_selected.emit(selected_object)

	
func _on_entered_viewport(in_viewport:bool):
	if in_viewport:
		set_process_input(true)
		set_physics_process(true)
		set_process(true)
	else:
		set_process_input(false)
		set_physics_process(false)
		set_process(false)

func _on_object_selected(_ob:Node3D)->void:
	pass

## does a proper removal of this node
func remove():

	instance = null
	queue_free()
