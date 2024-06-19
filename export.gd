extends SceneTree


## --export-release windows_64 C:/Users/thesw/OneDrive/Desktop/PuggosWorld/build/Windows/puggos_world.exe

## used with godot --headless -s export.gd

var export_path: String = "C:/Users/thesw/OneDrive/Desktop/PuggosWorld/build/Windows/puggos_world.exe"

func _init():
	
	print("Hello!")
	var output = []
	var exit_code = OS.execute("godot", ["--headless", "--export-release", "windows_64", export_path], output)
	print(output)
	print(exit_code)
	quit()
