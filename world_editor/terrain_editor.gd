extends Node3D

class_name  TerrainEditor

var camera_3d:Camera3D

var mouselook_engaged:bool = false


func start_operation():
	pass
	
func stop_operation():
	pass
	
func initiate():
	set_process(false)	
	PlayerInput.mouselook_engaged.connect(_on_engage_mouselook)
	PlayerInput.mouselook_disengaged.connect(_on_disengage_mouselook)
	
	PlayerInput.operation_started.connect(start_operation)
	PlayerInput.operation_stopped.connect(stop_operation)

func _on_changed_editor_context(old_context:Editor.CurrentEditorContext, new_context:Editor.CurrentEditorContext):
	if new_context == Editor.CurrentEditorContext.TERRAIN_EDIT:
		set_process(true)
	else:
		set_process(false)

func _on_engage_mouselook():
	mouselook_engaged = true
	
func _on_disengage_mouselook():
	mouselook_engaged = false
