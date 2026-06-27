extends Node2D

const tooltip_scene: PackedScene = preload("res://scenes/UI/tooltip_box.tscn")
@onready var food: CPUParticles2D = %food_particles
@onready var tooltip_container: Node = %VBoxContainer

var tooltips: Dictionary[String,TooltipBox] = {}

func _process(_delta: float) -> void:
	var game: GameData = GameData.get_game()
	
	var tooltip_strings: Array[String] = game.get_tooltip()
	
	# centered on mouse by default
	global_position = get_global_mouse_position() - Vector2(tooltip_container.get_combined_minimum_size().x * 0.5, tooltip_container.get_combined_minimum_size().y * 1.0)
	# Reject going past screen vertically
	if global_position.y < 10:
		global_position.y = 10
	# Reject going past screen left
	if global_position.x < 10:
		global_position.x = 10
	# Reject going past screen right
	if global_position.x + tooltip_container.get_combined_minimum_size().x > get_viewport_rect().size.x - 10:
		global_position.x = get_viewport_rect().size.x - tooltip_container.get_combined_minimum_size().x - 10
	
	
	%food_particles.global_position = get_global_mouse_position()
	
	fix_textboxes(tooltip_strings)
	
	
	var held: float = game.held_food()
	
	if held > 0.0:
		var temp: int = roundi(sqrt(held))
		if abs(food.amount - temp) > 1:
			food.amount = temp
		var rad: float = (0.8 * sqrt(held)) + 4.0
		if abs(food.emission_sphere_radius - rad) >= 3.2:
			food.emission_sphere_radius = rad
		if !food.emitting:
			food.emitting = true
	else:
		food.emitting = false


func fix_textboxes(input: Array[String]) -> void:
	var list: Array[String] = input.duplicate()
	
	for key in tooltips.keys():
		if !list.has(key):
			tooltip_container.remove_child(tooltips[key])
			tooltips[key].queue_free()
			#tooltips[key].hide()
			tooltips.erase(key)
	
	for item in list:
		if item.length() > 0 and !tooltips.has(item):
			
			var temp: TooltipBox = tooltip_scene.instantiate()
			tooltip_container.add_child(temp)
			temp.relabel.call_deferred(item)
			tooltips[item] = temp
	
