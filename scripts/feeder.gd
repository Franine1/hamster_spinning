class_name Feeder
extends LevelObject


var mouse_held: bool = false

func on_click() -> void:
	var game: GameData = GameData.get_game()
	
	mouse_held = true
	
	game.grab_food()



func _process(delta: float) -> void:
	super(delta)
	
	
	var game: GameData = GameData.get_game()
	
	if mouse_held and (!Input.is_action_pressed("Place Structure") or game.held_food() <= 0.0):
		mouse_held = false
		game.release_food()
	
