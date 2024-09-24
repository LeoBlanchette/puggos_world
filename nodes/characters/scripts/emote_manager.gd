extends Node3D

class_name EmoteManager

@onready var player: Player = $".."

@onready var emote_anchors: Node3D = $EmoteAnchors
@onready var emote_point_top: Marker3D = $EmoteAnchors/EmotePointTop
@onready var emote_point_left: Marker3D = $EmoteAnchors/EmotePointLeft
@onready var emote_point_right: Marker3D = $EmoteAnchors/EmotePointRight
@onready var emote_point_middle: Marker3D = $EmoteAnchors/EmotePointMiddle
@onready var emote_drawing: EmoteDrawing = $EmoteDrawing

const EMOTE = preload("res://nodes/emote/emote.tscn")

var emote_point_top_screen_position:Vector2 = Vector2.ZERO
var emote_point_left_screen_position:Vector2 = Vector2.ZERO
var emote_point_right_screen_position:Vector2 = Vector2.ZERO
var emote_point_middle_screen_position:Vector2 = Vector2.ZERO

var current_emote:Emote = null

@export var testing = false

func _ready() -> void:
	player.emote_changed.connect(_on_emote_changed)
	if not testing:
		emote_drawing.queue_free()

func _process(delta: float) -> void:
	set_anchor_points_to_face_camera()
	set_emote_points()	
	draw_testing_marks()
	position_emote()


func set_anchor_points_to_face_camera():
	#position = Vector3(0, 0, 0)
	#var theta = atan2(-camera_3d.position.x-emote_anchors.position.x, -camera_3d.position.z-emote_anchors.position.z)
	#emote_anchors.set_rotation(Vector3(0, theta, 0))
	emote_anchors.look_at(get_viewport().get_camera_3d().global_position) 
	emote_anchors.rotation_degrees = emote_anchors.rotation_degrees * Vector3(0, 1, 0)


func set_emote_points():
	emote_point_top_screen_position = HelperFunctions.get_screenpoint_from_position(emote_point_top.global_transform.origin)
	emote_point_left_screen_position = HelperFunctions.get_screenpoint_from_position(emote_point_left.global_transform.origin)
	emote_point_right_screen_position = HelperFunctions.get_screenpoint_from_position(emote_point_right.global_transform.origin)
	emote_point_middle_screen_position = HelperFunctions.get_screenpoint_from_position(emote_point_middle.global_transform.origin)

func draw_testing_marks():
	if not testing: 
		return
	emote_drawing.show_point_locations = [
		emote_point_top_screen_position,
		emote_point_left_screen_position,
		emote_point_right_screen_position,
		emote_point_middle_screen_position,
	]

func position_emote():
	if current_emote == null:
		return
	var emote_type:Types.EmoteType = current_emote.emote_type
	match emote_type:
		Types.EmoteType.THOUGHT:
			current_emote.position_emote(emote_point_left_screen_position)
		Types.EmoteType.URGENT_THOUGHT:
			current_emote.position_emote(emote_point_left_screen_position)
		Types.EmoteType.COMMUNICATION:
			current_emote.position_emote(emote_point_top_screen_position)
		Types.EmoteType.URGENT_COMMUNICATION:
			current_emote.position_emote(emote_point_top_screen_position)

func _on_emote_changed(id:int)->void:
	print("EMOTE %s"%str(id))
	current_emote = EMOTE.instantiate()
	emote_point_top.add_child(current_emote)
	current_emote.activate(id, 128, 4, Types.EmoteType.THOUGHT)
