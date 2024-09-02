extends EditorExportPlugin

class_name PWExporter

const DOCS:String = "res://docs/cmd/"
var export_folder:String = ""

func _get_name() -> String:
	return "PWExporter"

func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
	export_folder = get_directory_of_file(path)
	copy_docs()

## Copies over the in-game docs. The text files cannot be read at runtime,
## so we put them in the exe folder. 
func copy_docs():
	var dir = DirAccess.open(export_folder)
	dir.make_dir("docs/")
	dir.make_dir("docs/cmd/")
	var src = DirAccess.open(DOCS)
	var doc_files = src.get_files()
	for doc in doc_files:
		var text:String = get_cmd_doc(doc)
		save_doc(text, "%sdocs/cmd/%s"%[export_folder, doc])

## Get the directory of target file.
func get_directory_of_file(export_path:String)->String:
	var split_export_path:Array = export_path.split("/")
	var file_name:String = split_export_path[-1]
	var destination_dir = export_path.replace(file_name, "")
	return destination_dir

## Specifically gets a CMD doc.
func get_cmd_doc(doc:String)->String:
	const DOCS:String = "res://docs/cmd/"
	var file_path:String = "%s%s"%[DOCS, doc]
	if not FileAccess.file_exists(file_path):
		return ""
	var text = FileAccess.open(file_path, FileAccess.READ).get_as_text()
	return text

## Saves a text doc.
func save_doc(text, path):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	
