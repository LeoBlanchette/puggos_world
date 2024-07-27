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
var _mouse_position = Vector2(0.0, 0.0)
var _total_pitch = 0.0

# Movement state
var _direction = Vector3(0.0, 0.0, 0.0)
var _velocity = Vector3(0.0, 0.0, 0.0)
var _acceleration = 30
var _deceleration = -10
var _vel_multiplier = 4

# Keyboard state
var _w = false
var _s = false
var _a = false
var _d = false
var _q = false
var _e = false
var _shift = false
var _alt = false

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

func _exit_tree() -> void:
	if instance == self:
		instance = null
		
	#entered_viewport.disconnect(_on_entered_viewport)
	#object_selected.disconnect(UIWorldEditor.instance._on_object_selected)

func _input(event):
	# Receives mouse motion
	if event is InputEventMouseMotion:
		_mouse_position = event.relative
	
	# Receives mouse button input
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_RIGHT: # Only allows rotation if right click down
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)
			MOUSE_BUTTON_WHEEL_UP: # Increases max velocity
				_vel_multiplier = clamp(_vel_multiplier * 1.1, 0.2, 20)
			MOUSE_BUTTON_WHEEL_DOWN: # Decereases max velocity
				_vel_multiplier = clamp(_vel_multiplier / 1.1, 0.2, 20)
			MOUSE_BUTTON_LEFT:
				if event.pressed:
					select_target()

	# Receives key input
	if event is InputEventKey:
		match event.keycode:
			KEY_W:
				_w = event.pressed
			KEY_S:
				_s = event.pressed
			KEY_A:
				_a = event.pressed
			KEY_D:
				_d = event.pressed
			KEY_Q:
				_q = event.pressed
			KEY_E:
				_e = event.pressed
			KEY_SHIFT:
				_shift = event.pressed
			KEY_ALT:
				_alt = event.pressed

func _physics_process(delta: float) -> void:
	get_current_target()

# Updates mouselook and movement every frame
func _process(delta):
	_update_mouselook()
	_update_movement(delta)

# Updates camera movement
func _update_movement(delta):
	# Computes desired direction from key states
	_direction = Vector3(
		(_d as float) - (_a as float), 
		(_e as float) - (_q as float),
		(_s as float) - (_w as float)
	)
	
	# Computes the change in velocity due to desired direction and "drag"
	# The "drag" is a constant acceleration on the camera to bring it's velocity to 0
	var offset = _direction.normalized() * _acceleration * _vel_multiplier * delta \
		+ _velocity.normalized() * _deceleration * _vel_multiplier * delta
	
	# Compute modifiers' speed multiplier
	var speed_multi = 1
	if _shift: speed_multi *= SHIFT_MULTIPLIER
	if _alt: speed_multi *= ALT_MULTIPLIER
	
	# Checks if we should bother translating the camera
	if _direction == Vector3.ZERO and offset.length_squared() > _velocity.length_squared():
		# Sets the velocity to 0 to prevent jittering due to imperfect deceleration
		_velocity = Vector3.ZERO
	else:
		# Clamps speed to stay within maximum value (_vel_multiplier)
		_velocity.x = clamp(_velocity.x + offset.x, -_vel_multiplier, _vel_multiplier)
		_velocity.y = clamp(_velocity.y + offset.y, -_vel_multiplier, _vel_multiplier)
		_velocity.z = clamp(_velocity.z + offset.z, -_vel_multiplier, _vel_multiplier)
	
		translate(_velocity * delta * speed_multi)

# Updates mouse look 
func _update_mouselook():
	# Only rotates mouse if the mouse is captured
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_mouse_position *= sensitivity
		var yaw = _mouse_position.x
		var pitch = _mouse_position.y
		_mouse_position = Vector2(0, 0)
		
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

func _on_object_selected(ob:Node3D)->void:
	pass

## does a proper removal of this node
func remove():

	instance = null
	queue_free()
