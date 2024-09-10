extends Node

## api_name is the string id of the achievement. 
## info should be an arbitrary variable or dictionary 
## relevant to the operation.
signal achievement(api_name, info)
signal text_achievement(text)

func activate():
	achievement.connect(do_achievement)
	text_achievement.connect(do_text_achievement)
	
func do_achievement(api_name, _info={})->void:
	var _achievement = Steam.getAchievement(api_name)

	if not _achievement.ret || _achievement.achieved:
		return
		
	match api_name:
		"started_game":
			Steam.setAchievement(api_name)
		"did_cmd":
			Steam.setAchievement(api_name)
		"potty_mouth":
			Steam.setAchievement(api_name)
		"pretty_please":
			Steam.setAchievement(api_name)
		"got_kicked":
			Steam.setAchievement(api_name)
		"prefab_editor":
			Steam.setAchievement(api_name)
		"world_editor":
			Steam.setAchievement(api_name)
		"entered_world":
			Steam.setAchievement(api_name)			
		"created_character":
			Steam.setAchievement(api_name)
		"spawn_item":
			Steam.setAchievement(api_name)
		_:
			pass
			
	Steam.storeStats()

func do_text_achievement(text:String):
	
	if text.begins_with("/"):
		achievement.emit("did_cmd")
		
	if text.begins_with("/spawn "):
		achievement.emit("spawn_item")
		
	if "fuck" in text.to_lower():
		achievement.emit("potty_mouth")
	
	if is_begging(text):
		achievement.emit("pretty_please")

func is_begging(text:String):
	var _achievement = Steam.getAchievement("pretty_please")
	if not _achievement.ret || _achievement.achieved:
		return false
		
	text = text.to_lower()
	if "can i have my stuff back" in text:
		return true
	if "give me my stuff back" in text:
		return true
	if "i want my stuff back" in text:
		return true
	if "give it back" in text:
		return true	
	return false
		
