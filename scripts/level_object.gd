class_name LevelObject
extends StaticBody2D

##audio on click
@onready var click_sound = preload("res://sfx/hamster factory sounds/squeak.wav")

@export var template: Structure = null

@export var placement_mode: mode = mode.WAITING

@export var clickable_text: String = "Click to boost!"

@export var deletion_unlock: int = -1

var snap_positions: Array[Node2D] = []

enum mode {
	WAITING,
	HOVER,
	PLACED
}

var stored_food: float = 0.0

var collider: CollisionShape2D
var sprite
var placement_offset: Vector2 = Vector2.ZERO
var click_player: AudioStreamPlayer
var error_player: AudioStreamPlayer
var eat_player: AudioStreamPlayer


func _ready() -> void:

	sprite = Sprite2D.new()
	add_sibling.call_deferred(sprite)
	##audio click
	click_player = AudioStreamPlayer.new()
	#click_player.stream = click_sound
	add_child(click_player)
	error_player = AudioStreamPlayer.new()
	add_child(error_player)
	eat_player = AudioStreamPlayer.new()
	add_child(eat_player)
	##audio click
	collider = CollisionShape2D.new()
	add_child(collider)
	
	if template != null:
		refresh.call_deferred(template,(placement_mode == mode.PLACED))
	
	


func terminate() -> void:
	var game: GameData = GameData.get_game()
	
	if deletion_unlock >= 0:
		game.add_space(deletion_unlock)
	
	sprite.get_parent().remove_child(sprite)
	sprite.queue_free()
	get_parent().remove_child(self)
	queue_free()





## Corrects the sprite2D and collision shape based on the input structure
func refresh(input: Structure = template, use_animation: bool = false) -> void:
	template = input
	
	if template == null or template.get_animation() == null or !use_animation:
		if !sprite is Sprite2D:
			sprite.get_parent().remove_child(sprite)
			sprite.queue_free()
			sprite = Sprite2D.new()
			add_sibling.call_deferred(sprite)
		
		if template == null:
			sprite.texture = null
			return
		else:
			sprite.texture = template.image
	else:
		sprite.get_parent().remove_child(sprite)
		sprite.queue_free()
		sprite = template.get_animation().instantiate()
		add_sibling.call_deferred(sprite)
		
	
	sprite.use_parent_material = true
	
	if placement_mode == mode.HOVER:
		click_player.stream = template.placement_sound
	else:
		click_player.stream = template.click_sound
		
		if template.recolor != null:
			sprite.use_parent_material = false
			sprite.material = template.recolor
			print("found")
	
	var bounds = template.size
	
	
	if sprite is Sprite2D:
		sprite.scale = Vector2(bounds) / sprite.texture.get_size()
		
	elif sprite is AnimationManager:
		var sz = sprite.sprite_frames.get_frame_texture(sprite.animation,sprite.frame).get_size()
		sprite.scale = Vector2(bounds) / sz
		
		sprite.start()
	
	
	var temp: RectangleShape2D = RectangleShape2D.new()
	temp.size = Vector2(bounds) - Vector2(1.0,1.0)
	collider.shape = temp
	
	placement_offset = (bounds/32.0).ceil()
	placement_offset *= 16.0


func place(pos: Vector2) -> void:
	global_position = (32.0 * (pos/32.0).floor()) + placement_offset


func coordinates() -> Vector2:
	return global_position - placement_offset


func contacts(pos: Vector2) -> bool:
	
	var space: Rect2 = Rect2(global_position - placement_offset,placement_offset * 2)
	
	return space.has_point(pos)


func _process(delta: float) -> void:
	sprite.global_position = global_position
	sprite.z_index = z_index
	
	var game: GameData = GameData.get_game()
	
	var mouse_pos: Vector2 = get_global_mouse_position()
	
	match placement_mode:
		mode.WAITING:
			visible = false
		mode.HOVER:
			if template == null:
				visible = false
				
			else:
				
				var best_position: Vector2 = mouse_pos
				var best_dist: float = INF
				var coordinate_index: int = -1
				
				for i in snap_positions.size():
					var pos: Vector2 = snap_positions[i].global_position
					if snap_positions[i].has_method("coordinates"):
						pos = snap_positions[i].coordinates()
					var dist: float = mouse_pos.distance_squared_to(pos)
					if dist < best_dist:
						best_dist = dist
						best_position = pos
						coordinate_index = i
				
				visible = true
				collision_layer = 0
				collision_mask = 1
				z_index = 20
				modulate = Color(1.0,1.0,1.0,0.75)
				place(best_position)
				
				var collision = test_move(transform,Vector2.ZERO,null,0.08,true)
				
				if (!collision or template.tier > 0) and (template.tier == 0 or coordinate_index != -1):
					
					var affordable: bool = true
					var replacement_cost: Vector3 = Vector3.ZERO
					
					if collision and snap_positions[coordinate_index] is LevelObject and template.copy_cost:
						game.set_tooltip(snap_positions[coordinate_index].template.tooltip(),0.05,"space_purchasing")
						replacement_cost = snap_positions[coordinate_index].template.cost()
						affordable = Structure.affordable(replacement_cost)
						
						if template.size != snap_positions[coordinate_index].template.size:
							var new_template = template.duplicate()
							new_template.size = snap_positions[coordinate_index].template.size
							#new_template.image = snap_positions[coordinate_index].template.image
							var pos = coordinates()
							refresh(new_template)
							place(pos)
					
					if affordable:
						recoloration(Color.GREEN)
					else:
						recoloration(Color.YELLOW)
						
					#if Input.is_action_just_pressed("Place Structure") and !affordable:
						#if template.error_sound:
							#error_player.volume_db = -6
							#error_player.pitch_scale = randf_range(0.95, 1.05)
							#error_player.play()
					
					
					
					
					if Input.is_action_just_pressed("Place Structure") and affordable:
						var temp_old: Structure = template
						
						if collision and snap_positions[coordinate_index] is LevelObject:
							if template.copy_cost:
								Structure.expend(replacement_cost)
							temp_old = snap_positions[coordinate_index].template
							game.change_food(snap_positions[coordinate_index].stored_food)
							snap_positions[coordinate_index].terminate()
						
						var temp = self.duplicate()
						temp.placement_mode = mode.PLACED
						
						if get_parent() is CanvasGroup:
							get_parent().add_sibling(temp)
						else:
							add_sibling(temp)
						
						
						click_player.volume_db = -10
						##click_player.volume_db = randf_range(-1.0, 1.0)
						click_player.pitch_scale = 1.0
						click_player.play()
						
						
						if temp_old != template:
							if template.feature_copy_mode != Structure.mode.REPLACE:
								var replacement: Structure = template.duplicate()
								
								match template.feature_copy_mode:
									Structure.mode.COPY:
										replacement.clickable = temp_old.clickable
										replacement.expensive_click = temp_old.expensive_click
										replacement.indestructible = temp_old.indestructible
										replacement.constant_output = temp_old.constant_output
										replacement.partial_output = temp_old.partial_output
									Structure.mode.COMPARE_AND:
										replacement.clickable = temp_old.clickable and replacement.clickable
										replacement.expensive_click = temp_old.expensive_click and replacement.expensive_click
										replacement.indestructible = temp_old.indestructible and replacement.indestructible
										replacement.constant_output = temp_old.constant_output and replacement.constant_output
										replacement.partial_output = temp_old.partial_output and replacement.partial_output
									Structure.mode.COMPARE_OR:
										replacement.clickable = temp_old.clickable or replacement.clickable
										replacement.expensive_click = temp_old.expensive_click or replacement.expensive_click
										replacement.indestructible = temp_old.indestructible or replacement.indestructible
										replacement.constant_output = temp_old.constant_output or replacement.constant_output
										replacement.partial_output = temp_old.partial_output or replacement.partial_output
									
								get_tree().create_timer(0.1).timeout.connect(temp.refresh.bind(replacement,true))
						
						game.set_blueprint()
						game.add_unlocks(template)
						#print("placed")
				else:
					recoloration(Color.RED)
			
			
			
		mode.PLACED:
			recoloration(Color.WHITE)
			visible = true
			collision_layer = 1 if template.do_physics else 0
			collision_mask = 0
			z_index = 19
			modulate = Color(1.0,1.0,1.0,1.0) if template.do_visibility else Color(1.0,1.0,1.0,0.0)
			sprite.modulate = modulate
			
			if sprite is AnimationManager:
				sprite.alt_condition(!template.clickable)
			
			var hovering: bool = contacts(mouse_pos) and game.get_blueprint() == null
			
			if hovering:
				
				#var food_request: float = template.max_food_storage - stored_food
				#if food_request >= 0.0:
					#stored_food += game.take_food(food_request)
					
				var food_request: float = template.max_food_storage - stored_food
				if food_request >= 0.0:
					var taken := game.take_food(food_request)
					if taken > 0.0:
						stored_food += taken

						# Play food sound
						if template.eat_sound:
							eat_player.stream = template.eat_sound
							eat_player.volume_db = -8
							eat_player.pitch_scale = randf_range(0.95, 1.05)
							eat_player.play()

				
				
				
				if template.clickable:
					game.set_tooltip(clickable_text,0.05, "click_tooltip")
					
					if Input.is_action_just_pressed("Place Structure"):
						##audio
						click_player.volume_db = -10
						##click_player.volume_db = randf_range(-1.0, 1.0)
						click_player.pitch_scale = randf_range(0.9, 1.1)
						click_player.play()
						
						on_click()
			
			var output: float = 0.0
			
			if template.constant_output:
				output = transact_resources(delta)
				
				if sprite is AnimationManager:
					sprite.start(output >= 0.05)
			
			
			if hovering:
				var extra_tooltip: String = template.description if template.do_visibility else ""
				var reported_output = output if template.constant_output else 1.0
				# Extra tooltip for efficiency
				# if template.constant_output:
				# 	extra_tooltip += "\n"
				# 	extra_tooltip += "Efficiency: " + str(snapped(output* 100.0,0.1))

				# Inputs tooltip
				if template.HP_input > 0.0:
					extra_tooltip += "\n"
					extra_tooltip += "HP Input: " + str(snapped(template.HP_input,0.1))
				if template.money_input > 0.0:
					extra_tooltip += "\n"
					extra_tooltip += "Money Input: " + str(snapped(template.money_input,0.1))
				if template.food_input > 0.0:
					extra_tooltip += "\n"
					extra_tooltip += "Food Input: " + str(snapped(template.food_input,0.1))

				# Outputs tooltip
				if template.HP_output > 0.0:
					extra_tooltip += "\n"
					extra_tooltip += "HP Output: " + str(snapped(template.HP_output*reported_output,0.1))
				if template.money_output > 0.0:
					extra_tooltip += "\n"
					extra_tooltip += "Money Output: " + str(snapped(template.money_output*reported_output,0.1))
				if template.food_output > 0.0:
					extra_tooltip += "\n"
					extra_tooltip += "Food Output: " + str(snapped(template.food_output*reported_output,0.1))

				# Food storage tooltip
				if template.max_food_storage > 0.0:
					extra_tooltip += "\n"
					extra_tooltip += "Food Storage: " + str(snapped(stored_food,0.1)) + "/" + str(snapped(template.max_food_storage,0.1))
				
				if extra_tooltip.length() > 0 and template.do_visibility:
					game.set_tooltip(extra_tooltip,0.05, "production_tooltip")


func on_click() -> void:
	transact_resources(1.0,template.expensive_click)



func transact_resources(delta: float, do_input: bool = true, do_output: bool = true) -> float:
	var game: GameData = GameData.get_game()
	
	var best_rate = delta
	
	if do_input:
		if template.HP_input != 0.0:
			best_rate = min(best_rate,game.get_HP()/template.HP_input)
		if template.money_input != 0.0:
			best_rate = min(best_rate,game.get_money()/template.money_input)
		if template.food_input != 0.0:
			best_rate = min(best_rate,stored_food/template.food_input)
	
	if best_rate < delta and !template.partial_output:
		return 0.0
	
	
	var hp = 0.0
	var money = 0.0
	var food_out = 0.0
	var food_in = 0.0
	
	if do_input:
		hp -= template.HP_input
		money -= template.money_input
		food_in -= template.food_input
	if do_output:
		hp += template.HP_output
		money += template.money_output
		food_out += template.food_output
	
	game.change_HP(hp * best_rate)
	game.change_money(money * best_rate)
	game.change_food(food_out * best_rate)
	stored_food = clamp(stored_food+(food_in*best_rate),0.0,template.max_food_storage)
	
	return clamp(best_rate / delta,0.0,1.0)


func recoloration(input: Color) -> void:
	var par = get_parent()
	if par is CanvasGroup:
		if par.material is ShaderMaterial:
			#print("recolor")
			par.material.set_shader_parameter("color_reshading",input)
