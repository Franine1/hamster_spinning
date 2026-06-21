extends Control




var current_state: state = state.GAME

@onready var game_VP: SubViewport = %"game viewport"
@onready var shop_VP: SubViewport = %"shop viewport"

enum state {
	GAME,
	SHOP,
	BLUEPRINT
}


func _process(delta: float) -> void:
	var game: GameData = GameData.get_game()
	
	if Input.is_action_just_pressed("Switch Screen"):
		match current_state:
			state.GAME:
				current_state = state.SHOP
			state.SHOP:
				current_state = state.GAME
			state.BLUEPRINT:
				game.set_blueprint()
				current_state = state.GAME
	
	
	
	match current_state:
		state.GAME:
			game_VP.handle_input_locally = true
			%"game container".mouse_target = true
			shop_VP.handle_input_locally = false
			%"shop container".mouse_target = false
			glide_VP_towards(0.0,delta*2.0)
			
		state.SHOP:
			game_VP.handle_input_locally = false
			%"game container".mouse_target = false
			shop_VP.handle_input_locally = true
			%"shop container".mouse_target = true
			glide_VP_towards(-0.5,delta*2.0)
			
			if game.get_blueprint() != null:
				current_state = state.BLUEPRINT
		
		state.BLUEPRINT:
			game_VP.handle_input_locally = true
			%"game container".mouse_target = true
			shop_VP.handle_input_locally = false
			%"shop container".mouse_target = false
			glide_VP_towards(0.0,delta*2.0)
			
			if game.get_blueprint() == null:
				current_state = state.GAME
			


func glide_VP_towards(target: float, delta: float) -> void:
	var diff = target - %"playable windows".offset_transform_position_ratio.x
	var diff_sign = -1.0 if diff < 0.0 else 1.0
	var length = min(abs(diff),delta)
	
	%"playable windows".offset_transform_position_ratio.x += length * diff_sign
