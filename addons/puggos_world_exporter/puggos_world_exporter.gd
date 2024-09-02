@tool
extends EditorPlugin


func _enter_tree() -> void:
	var pw_exporter: PWExporter =PWExporter.new()
	add_export_plugin(pw_exporter)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
