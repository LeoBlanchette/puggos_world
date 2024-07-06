extends Node

class_name SaveableTextArray
var text_array:Array = []
func _init(_text_array:Array=[]) -> void:
	text_array = _text_array

func save(path:String):
	var textified = ""
	for text in text_array:
		textified+=text+"\n"
	var text_to_save = FileAccess.open(path, FileAccess.WRITE)
	text_to_save.store_string(textified)

func load_array(file_path:String)->Array:
	var arr := []
	var f := FileAccess.open(file_path, FileAccess.READ)
	if f == null:
		return []
	while not f.eof_reached():
		var line:String = f.get_line()
		if line.is_empty():
			continue
		arr.append(line)
	return arr
