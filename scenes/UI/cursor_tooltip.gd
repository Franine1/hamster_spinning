extends Node2D


@onready var textbox: RichTextLabel = %RichTextLabel

func _process(_delta: float) -> void:
	var game: GameData = GameData.get_game()
	
	var tooltip: String = game.get_tooltip()
	
	
	if tooltip == "":
		hide()
	else:
		show()
		global_position = get_global_mouse_position()
		textbox.text = tooltip
