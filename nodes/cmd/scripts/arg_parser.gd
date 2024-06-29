class_name ArgParser
var arguments = {}

func _init(argument_string:String):		
	var args = parse(argument_string)
	var args_named:Dictionary = {"args": args}
	var named_arg_elements:Array = []
	var populating_named_arg:bool = false
	
	var i:int = 1
	for arg:String in args:
		if arg.begins_with("/"):
			continue
		if arg.begins_with("-"):
			continue
		args_named[str(i)] = arg
		i=i+1
	
	#get the named args
	for arg:String in args:
		
		if arg.begins_with("/"):
			args_named["command"] = arg
		
		if arg.begins_with("--") && populating_named_arg:
			args_named[named_arg_elements[0]] = named_arg_elements.slice(1)
			named_arg_elements = []
			populating_named_arg = false
			
		if arg.begins_with("--") && !populating_named_arg:
			populating_named_arg = true
			named_arg_elements.append(arg)
			continue
			
		if populating_named_arg:
			named_arg_elements.append(arg)
	
	if named_arg_elements.size() > 0:
		args_named[named_arg_elements[0]] = named_arg_elements.slice(1)
	args_named["argument_string"] = argument_string
	arguments = args_named

func parse(command:String) -> PackedStringArray:
	var command_parsed = command.split(" ", false)
	
	var command_dict:Dictionary = {}
	
	command_dict["args"] = command_parsed

	return command_parsed

func get_argument(arg: String, default_value = null):
	if arguments.has(arg):
		return arguments[arg]
	else:
		return default_value

func get_command()->String:
	return arguments["command"]

static func vector_from_array(l:Array)->Vector3:
	var v:Vector3 = Vector3.ZERO	
	if l.size() == 0:
		return v
	if l.size() >= 1:
		v.x=float(l[0])
	if l.size() >= 2:
		v.y=float(l[1])
	if l.size() >= 3:
		v.z=float(l[2])
	return v

static func array_from_vector(v:Vector3)->Array:
	return [v.x, v.y, v.z]

static func string_argument_from_vector(arg:String, v:Vector3):	
	var s:String = "{arg} {x} {y} {z}".format({"arg":arg, "x":v.x,"y":v.y, "z":v.z})
	return s

func print_arguments()-> void:
	print(arguments)
