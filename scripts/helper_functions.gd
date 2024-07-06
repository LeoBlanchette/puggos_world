extends Node

enum Scan { FULL, FILES_ONLY, DIRECTORIES_ONLY }

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
	else:
		print("An error occurred when trying to access the path: "+dir_path)

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
	
