extends Node

const HOME = "res://mods/"

var _pwd = ""
var dir:DirAccess 

func _ready() -> void:
	dir = DirAccess.open(HOME)
	_pwd = dir.get_current_dir()
	
func ls(command:ArgParser):
	var path:String = _pwd
	var target_dir:String = command.get_second_argument()
	
	if not target_dir.is_empty() && target_dir != "/":
		path = "%s/%s"%[path, target_dir]
	
	if target_dir == "/":
		path = HOME
	
	path = trim_end_slash(path)	
	
	if not is_dir(path):
		Cmd.print_error_to_console("%s does not exist."%path)
		return
	
	var contents:Array[String]=dir_contents(path, true)
	var decorated_lines:Array[String] = decorate_output(contents)
	
	#FINAL OUTPUT
	Cmd.print_to_console(decorate_mod_path(path))
	for line:String in decorated_lines:
		Cmd.print_to_console(line)

func pwd(command:ArgParser):
	var line:String = decorate_mod_path(_pwd)
	Cmd.print_to_console(line)
	
func cd(command:ArgParser):
	var arg:String = command.get_second_argument()
		
	var path:String = "%s/%s"%[_pwd, trim_end_slash(arg)]
	
	if not is_dir(path):
		Cmd.print_error_to_console("%s does not exist."%path)
		return
		
	if arg == "/":
		path = HOME

	dir = DirAccess.open(path)

	_pwd = dir.get_current_dir()
	Cmd.cmd("/pwd")

## Tests to see if this is a directory. Presently dir.direxists
## returns false wrongly on imported projects, so we use this 
## method instead.
## See https://www.reddit.com/r/godot/comments/1f8gf8d/diraccess_didnt_work_why/
func is_dir(path:String)->bool:
	var test_dir:DirAccess = DirAccess.open(path)
	if test_dir == null:
		return false
	return true

func decorate_mod_path(path:String):
	var roygbiv:Array[Color]=[
		Color.RED,
		Color.ORANGE,
		Color.YELLOW,
		Color.CORNFLOWER_BLUE,
		Color.BLUE_VIOLET,
		Color.VIOLET,
	]
	var home_colored:String = Cmd.color_line("[b]res://[/b]", Color.BROWN)
	var colored_parts:Array[String]=[]
	var joiner:String = Cmd.color_line("/", Color.DARK_GRAY)
	var start:String = path.replace("res://", "")
	var parts:PackedStringArray=start.split("/")
	var i:int = 0
	for part in parts:
		if i <= roygbiv.size()-1:
			part = Cmd.color_line(part, roygbiv[i])
		else:
			part = Cmd.color_line(part, Color.WHITE)
		colored_parts.append(part)
		i = i+1
	var dirpath:String = joiner.join(colored_parts)
	dirpath = "%s%s"%[home_colored, dirpath]

	return dirpath
		

func decorate_output(lines:Array[String])->Array[String]:
	var decorated_output:Array[String]=[]
	for line in lines:
		if line.begins_with("DIR:"):
			line = decorate_directory_string(line)
		if line.begins_with("FILE:"):
			line = decorate_file_string(line)
		decorated_output.append(line)
		
	return decorated_output

func trim_end_slash(path:String)->String:
	if path.ends_with("/"):
		path = path.erase(path.length() -1, 1)
	return path

func decorate_directory_string(line:String)->String:
	return "	%s"%Cmd.color_line("%s/"%line.replace("DIR:", ""), Color.GREEN)
	
func decorate_file_string(line:String)->String:
	return "	%s"%Cmd.color_line(line.replace("FILE:", ""), Color.AQUA)

func dir_contents(path, mark=false)->Array[String]:
	var dirs:Array[String] = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if mark:
					dirs.append("DIR:%s" % clean(file_name))
				else:
					dirs.append(file_name)
			else:
				if mark:
					dirs.append("FILE:%s" % clean(file_name))
				else:
					dirs.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	
	return dirs

func clean(file_name:String)->String:
	if file_name.ends_with(".import"):
		file_name = file_name.replace(".import", Cmd.color_line(".import", Color.LIGHT_SLATE_GRAY))
	if file_name.ends_with(".remap"):
		file_name = file_name.replace(".remap", Cmd.color_line(".import", Color.LIGHT_SLATE_GRAY))
	return file_name
