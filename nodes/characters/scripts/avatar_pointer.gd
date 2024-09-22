extends Node3D

## Manages the way the avatar points independent from the camera's 
## rotation. Depending on idle and other conditions, the avatar
## should point original forward until the camera rotates so many 
## degrees, according to avatar_turn_threshold variable.
## Meanwhile, the head should always point the way the camera faces.
class_name AvatarPointer


#region connected parts
@export var player: Player 
@export var action_manager: ActionManager
@export var avatar: Avatar
@onready var skeleton_3d: Skeleton3D = $"../Avatar/Character/Armature/Skeleton3D"
@onready var animation_merger: AnimationMerger = $"../Avatar/Character/Armature/Skeleton3D/AnimationMerger"
#endregion 

#region main operation 
## The target that the head will look at.
@export var look_marker_tracker: Marker3D 
@export var head_bone_mirror: Marker3D
## How many degrees until the body points toward camera view.
@export var avatar_turn_threshold:float

## Which way the root player object was facing last time recorded
var last_player_facing_rotation:Vector3

## Checked during _process. If true, the avatar will lock rotation on player object forward.
var face_toward_last_facing_rotation:bool = false

## Pause avatar rotation assessment. This happens when avatar is rotating to new value.
var assessment_paused = false
#endregion 

#region avatar rotation
enum TurnDirection{
	CLOCKWISE,
	COUNTER_CLOCKWISE
}
var turn_direction = TurnDirection.CLOCKWISE
## The speed at which avatar rotates to new facing angle.
@export var avatar_rotation_speed:float = 1.0

## 0 to 1, the amount to "slerp" at. https://docs.godotengine.org/en/latest/tutorials/3d/using_transforms.html#interpolating-with-quaternions
@export var avatar_rotated_amount:float = 0.0

## Setting to true triggers the rotation of the avatar and pausing of all other assessments
var doing_avatar_rotation:bool = false

# In degrees
var starting_avatar_rotation:Vector3 = Vector3(0, 180, 0)
#endregion 

#region head pointing
@export var view_marker:Vector3 = Vector3.ZERO
#endregion 

func _ready() -> void:
	if not is_multiplayer_authority():
		return
	player.player_stopped.connect(update_facing_rotation)
	player.player_moved.connect(update_facing_rotation)
	update_view_target()
	align_avatar_with_player_object()


func _process(delta: float) -> void:
	update_view_target()
	look_at_focus_point()
	if not is_multiplayer_authority():
		return	
	align_avatar()	
	if doing_avatar_rotation:
		update_rotation_to_new_facing_direction(delta)
		return
	if player.is_moving:
		align_avatar_with_player_object()	
	if face_toward_last_facing_rotation:
		avatar.global_rotation_degrees = last_player_facing_rotation


func align_avatar():
	if assessment_paused:
		return
			
	if not player.is_moving:
		face_toward_last_facing_rotation = true
		if avatar_turn_threshold_met():
			rotate_avatar_to_new_facing_direction()
	else:
		face_toward_last_facing_rotation = false

func rotate_avatar_to_new_facing_direction():
	assessment_paused = true
	doing_avatar_rotation = true
	starting_avatar_rotation = avatar.rotation_degrees
	if must_turn_clockwise():
		turn_direction = TurnDirection.CLOCKWISE
	else:
		turn_direction = TurnDirection.COUNTER_CLOCKWISE

func update_rotation_to_new_facing_direction(delta: float):
	if avatar_rotated_amount >= 1:
		assessment_paused = false
		doing_avatar_rotation = false
		avatar_rotated_amount = 0
		starting_avatar_rotation = Vector3(0, 180, 0)
		update_facing_rotation()
		return
	avatar_rotated_amount += delta * avatar_rotation_speed

	var turn_degrees = avatar_rotated_amount * avatar_turn_threshold
	if turn_direction == TurnDirection.CLOCKWISE:
		avatar.rotation_degrees.y = starting_avatar_rotation.y - turn_degrees
	else:
		avatar.rotation_degrees.y = starting_avatar_rotation.y + turn_degrees

func update_facing_rotation():
	align_avatar_with_player_object()
	

func must_turn_clockwise()->bool:
	if avatar.rotation_degrees.y < 0:
		return true
	return false

func avatar_turn_threshold_met()->bool:
	if abs(avatar.rotation_degrees.y) < 90:
		return true
	return false

func align_avatar_with_player_object():
	last_player_facing_rotation = player.global_rotation_degrees - Vector3(0, 180, 0)
	update_view_target()
	look_at_focus_point()

func update_view_target():
	view_marker = player.projected_view_marker

func look_at_focus_point():
	if player.display_mode:
		animation_merger.enable_head_look(false)
		return
	if view_marker == Vector3.ZERO:
		return
	if player.is_long_idle:
		animation_merger.enable_head_look(false)
		return
	if player.is_moving:
		animation_merger.enable_head_look(false)
		return
	if action_manager.is_rate_limited:
		animation_merger.enable_head_look(false)
		return
	animation_merger.enable_head_look(true)
	animation_merger.head_look_at(view_marker)
