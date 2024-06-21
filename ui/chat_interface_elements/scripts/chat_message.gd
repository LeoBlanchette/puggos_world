extends HBoxContainer

@onready var texture_rect: TextureRect = $MarginContainer/TextureRect
@onready var chat_rich_text_label: RichTextLabel = $ChatRichTextLabel

func create_chat_message(steam_id:int, message:String):
	message = message.strip_edges()
	chat_rich_text_label.clear()	
	chat_rich_text_label.parse_bbcode(message)
	texture_rect.texture = Players.get_player_avatar(steam_id)	
