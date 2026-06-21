extends Control




var current_state: state = state.GAME

@onready var game_VP: SubViewport = %"game viewport"
@onready var shop_VP: SubViewport = %"shop viewport"

enum state {
	GAME,
	SHOP
}


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Switch Screen"):
		match current_state:
			state.GAME:
				current_state = state.SHOP
			state.SHOP:
				current_state = state.GAME
	
	
	
	match current_state:
		state.GAME:
			game_VP.handle_input_locally = true
			shop_VP.handle_input_locally = false
			glide_VP_towards(0.0,delta*2.0)
			
		state.SHOP:
			game_VP.handle_input_locally = false
			shop_VP.handle_input_locally = true
			glide_VP_towards(-0.5,delta*2.0)
			
			


func glide_VP_towards(target: float, delta: float) -> void:
	var diff = target - %"playable windows".offset_transform_position_ratio.x
	var diff_sign = -1.0 if diff < 0.0 else 1.0
	var length = min(abs(diff),delta)
	
	%"playable windows".offset_transform_position_ratio.x += length * diff_sign
