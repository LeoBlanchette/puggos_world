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
@onready var icon: TextureRect = $Icon

func _ready() -> void:
	pass

func activate(id:int, _size:int = 128, time:float = 3, _emote_type:Types.EmoteType = Types.EmoteType.NONE):
	if _emote_type == Types.EmoteType.NONE:
		return
		
	size = Vector2(_size, _size)
	pivot_offset =  Vector2(_size / 2, _size / 2)
	
	var texture2d = load(ObjectIndex.object_index.get_emote_icon_path(id))
	icon.texture = texture2d
	
	emote_type = _emote_type
	enqueue_removal(time)

func enqueue_removal(time:float):
	await get_tree().create_timer(time).timeout
	queue_free()

func show_emote():
	thought.hide()
	urgent_thought.hide()
	communication.hide()
	urgent_communication.hide()
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
