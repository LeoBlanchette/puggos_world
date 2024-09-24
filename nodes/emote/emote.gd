extends Control

class_name Emote

var emote_type = Types.EmoteType.NONE:
	set(value):
		emote_type = value
		show_emote()

@onready var thought: TextureRect = $THOUGHT
@onready var urgent_thought: TextureRect = $URGENT_THOUGHT
@onready var communication: TextureRect = $COMMUNICATION
@onready var urgent_communication: TextureRect = $URGENT_COMMUNICATION

func _ready() -> void:
	pass

func activate(id:int, _size:int = 128, time:float = 3, _emote_type:Types.EmoteType = Types.EmoteType.NONE):

	size = Vector2(_size, _size)
	pivot_offset =  Vector2(_size / 2, _size / 2)
	
	if _emote_type == Types.EmoteType.NONE:
		#THIS MEANS USE THE ID FOR SETUP
		pass
	else:
		emote_type = _emote_type
	enqueue_removal(time)

func enqueue_removal(time:float):
	await get_tree().create_timer(time).timeout
	queue_free()

func show_emote():
	match emote_type:
		Types.EmoteType.THOUGHT:
			thought.show()
		Types.EmoteType.URGENT_THOUGHT:
			urgent_thought.show()
		Types.EmoteType.COMMUNICATION:
			communication.show()
		Types.EmoteType.URGENT_COMMUNICATION:
			urgent_communication.show()

func position_emote(pos:Vector2):
	position = pos - size/2
