extends HBoxContainer

@onready var texture_rect: TextureRect = $MarginContainer/TextureRect
@onready var rich_text_label: RichTextLabel = $RichTextLabel

func create_chat_message(steam_id:int, message:String):
	rich_text_label.clear()	
	rich_text_label.parse_bbcode(message)
	texture_rect.texture = Players.get_player_avatar(steam_id)	
