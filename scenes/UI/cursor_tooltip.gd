extends Node2D


@onready var textbox: RichTextLabel = %RichTextLabel
@onready var food: CPUParticles2D = %food_particles

func _process(_delta: float) -> void:
	var game: GameData = GameData.get_game()
	
	var tooltip: String = game.get_tooltip()
	
	global_position = get_global_mouse_position()
	
	if tooltip == "":
		$PanelContainer.hide()
	else:
		$PanelContainer.show()
		textbox.text = tooltip
	
	
	var held: float = game.held_food()
	
	if held > 0.0:
		var temp: int = roundi(sqrt(held))
		if abs(food.amount - temp) > 1:
			food.amount = temp
		var rad: float = (held)/8.0 + 6.0
		if abs(food.emission_sphere_radius - rad) >= 3.2:
			food.emission_sphere_radius = rad
		if !food.emitting:
			food.emitting = true
	else:
		food.emitting = false
