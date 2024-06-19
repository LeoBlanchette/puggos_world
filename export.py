import subprocess
#https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html


godot = "C:/Users/thesw/OneDrive/Desktop/Godot/godot/bin/godot.windows.editor.x86_64.exe"
windows_64_export_path = "C:/Users/thesw/OneDrive/Desktop/PuggosWorld/build/Windows"


subprocess.run([godot, "--export-release", "windows_64", windows_64_export_path])

godot --export-release windows C:/Users/thesw/OneDrive/Desktop/PuggosWorld/build/Windows/puggos_world.exe