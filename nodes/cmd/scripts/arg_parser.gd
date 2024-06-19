class_name ArgParser
var arguments = {}

func _init(args: Array):		
	var args_named:Dictionary = {"args": args}
	var named_arg_elements:Array = []
	var populating_named_arg:bool = false
	
	var i:int = 1
	for arg:String in args:
		if arg.begins_with("/"):
			continue
		if arg.begins_with("-"):
			continue
		args_named[i] = arg
		i=i+1
	
	#get the named args
	for arg:String in args:
		
		if arg.begins_with("/"):
			args_named["command"] = arg
		
		if arg.begins_with("-") && populating_named_arg:
			args_named[named_arg_elements[0]] = named_arg_elements.slice(1)
			named_arg_elements = []
			populating_named_arg = false
			
		if arg.begins_with("-") && !populating_named_arg:
			populating_named_arg = true
			named_arg_elements.append(arg)
			continue
		if populating_named_arg:
			named_arg_elements.append(arg)
	
	if named_arg_elements.size() > 0:
		args_named[named_arg_elements[0]] = named_arg_elements.slice(1)

	arguments = args_named

func get_argument(arg: String, default_value = null):
	if arguments.has(arg):
		return arguments[arg]
	else:
		return default_value

func print_arguments()-> void:
	print(arguments)
