extends Node

enum Scan { FULL, FILES_ONLY, DIRECTORIES_ONLY }

func get_all_files_recursive(path: String, file_ext := "", files := []):
	var dir = DirAccess.open(path)
	if DirAccess.get_open_error() == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				files = get_all_files_recursive(dir.get_current_dir() +"/"+ file_name, file_ext, files)
			else:
				if file_ext and file_name.get_extension() != file_ext:
					file_name = dir.get_next()
					continue				
				files.append(dir.get_current_dir() +"/"+ file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access %s." % path)
	return files

func get_directory_contents(dir_path: String, scan_type: Scan = Scan.FULL) -> Array[String]:
	var contents_directories: Array[String] = []
	var contents_files: Array[String] = []
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				contents_directories.append(file_name)
			else:
				contents_files.append(file_name)
			file_name = dir.get_next()
	
	match scan_type:
		Scan.FULL:
			return contents_directories + contents_files
		Scan.DIRECTORIES_ONLY:
			return contents_directories
		Scan.FILES_ONLY:
			return contents_files
	
	return contents_directories + contents_files

func remove_bb_code(text:String) -> String:
	var regex = RegEx.new()
	regex.compile("\\[.*?\\]")
	return regex.sub(text, "", true)

## Takes an array of layer numbers and returns the mask https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html#codecell0
func get_layer_mask(layers:Array[int])->int:
	var mask:int = 0
	for layer in layers:
		mask+=pow(2, layer-1)
	return mask

func round_to_dec(num, decimals):
	num = float(num)
	decimals = int(decimals)
	var sgn = 1
	if num < 0:
			sgn = -1
			num = abs(num)
			pass
	var num_fraction = num - int(num) 
	var num_dec = round(num_fraction * pow(10.0, decimals)) / pow(10.0, decimals)
	var round_num = sgn*(int(num) + num_dec)
	return round_num

## Do not use except in special limited cases. Created for the "Prefab" object in World building.
## This should mainly be used for objects where size is known and traversal will not be heavy.
func get_all_children(in_node,arr:=[]):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr
