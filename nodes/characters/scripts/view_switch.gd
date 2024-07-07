extends Node

@onready var view_interaction: Node3D = $"../Head/ThirdPersonCameraReference/ViewInteraction"
@onready var first_person_camera_reference: Marker3D = $"../Head/FirstPersonCameraReference"
@onready var third_person_camera_reference: Marker3D = $"../Head/ThirdPersonCameraReference"

@export var cam_shoulder_offset := 1

var is_first_person_view: bool = false

func _ready() -> void:
	switch_to_third_person()

func _input(event: InputEvent) -> void:
	if not GameManager.instance.is_mouse_locked():
		return
	if event is InputEventKey:
		if Input.is_action_just_pressed("view_switch"):
			toggle_1st_3rd_person_view()
	
func toggle_1st_3rd_person_view():
	if is_first_person_view:
		switch_to_third_person()
	else:			
		switch_to_first_person()

func switch_to_third_person()->void:
		view_interaction.reparent(third_person_camera_reference)
		view_interaction.position = Vector3.ZERO
		is_first_person_view = false
		view_interaction.position.x = cam_shoulder_offset
	
func switch_to_first_person()->void:
		view_interaction.reparent(first_person_camera_reference)
		view_interaction.position = Vector3.ZERO
		is_first_person_view = true
		view_interaction.position.x = 0
