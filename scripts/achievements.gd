extends Node

## api_name is the string id of the achievement. 
## info should be an arbitrary variable or dictionary 
## relevant to the operation.
signal achievement(api_name, info)

func activate():
	achievement.connect(do_achievement)
	
func do_achievement(api_name, info={})->void:
	var _achievement = Steam.getAchievement(api_name)

	if not _achievement.ret || _achievement.achieved:
		return
		
	match api_name:
		"started_game":
			Steam.setAchievement(api_name)
		_:
			pass
			
	Steam.storeStats()
