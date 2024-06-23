extends MultiplayerSynchronizer

@export var position:Vector3:
	set(val):
		if is_multiplayer_authority():
			position = val
		else:
			get_parent().position = val

@export var rotation:Vector3:
	set(val):
		if is_multiplayer_authority():
			rotation = val
		else:
			get_parent().rotation = val
