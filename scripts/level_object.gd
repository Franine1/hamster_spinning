class_name LevelObject
extends StaticBody2D



@export var template: Structure = null

@export var placement_mode: mode = mode.WAITING

var snap_positions: Array[Node2D] = []

enum mode {
	WAITING,
	HOVER,
	PLACED
}

var collider: CollisionShape2D
var sprite: Sprite2D
var placement_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	sprite = Sprite2D.new()
	add_sibling.call_deferred(sprite)
	collider = CollisionShape2D.new()
	add_child(collider)
	if template != null:
		get_tree().create_timer(0.1).timeout.connect(refresh)
	
	


## Corrects the sprite2D and collision shape based on the input structure
func refresh(input: Structure = template) -> void:
	template = input
	
	if template == null:
		sprite.texture = null
		return
	
	var bounds = input.size
	
	sprite.texture = input.image
	
	sprite.use_parent_material = true
	
	sprite.scale = Vector2(bounds) / sprite.texture.get_size()
	
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

func click_reaction() -> void:
	pass


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
				
				if !collision or template.tier > 0:
					recoloration(Color.GREEN)
					
					if Input.is_action_just_pressed("Place Structure"):
						var temp_old: Structure = template
						
						if collision and snap_positions[coordinate_index] is LevelObject:
							temp_old = snap_positions[coordinate_index].template
							snap_positions[coordinate_index].get_parent().remove_child(snap_positions[coordinate_index])
							snap_positions[coordinate_index].queue_free()
						
						var temp = self.duplicate()
						temp.placement_mode = mode.PLACED
						if get_parent() is CanvasGroup:
							get_parent().add_sibling(temp)
						else:
							add_sibling(temp)
						
						if temp_old != template:
							if temp_old.clickable != template.clickable or temp_old.indestructible != template.indestructible:
								if template.feature_copy_mode != Structure.mode.REPLACE:
									var replacement: Structure = template.duplicate()
									
									match template.feature_copy_mode:
										Structure.mode.COPY:
											replacement.clickable = temp_old.clickable
											replacement.indestructible = temp_old.indestructible
										Structure.mode.COMPARE_AND:
											replacement.clickable = temp_old.clickable and replacement.clickable
											replacement.indestructible = temp_old.indestructible and replacement.indestructible
										Structure.mode.COMPARE_OR:
											replacement.clickable = temp_old.clickable or replacement.clickable
											replacement.indestructible = temp_old.indestructible or replacement.indestructible
									
									temp.template = replacement
								
						
						game.set_blueprint()
						game.add_unlocks(template)
						#print("placed")
				else:
					recoloration(Color.RED)
			
			
			
		mode.PLACED:
			recoloration(Color.WHITE)
			visible = true
			collision_layer = 1
			collision_mask = 0
			z_index = 19
			modulate = Color(1.0,1.0,1.0,1.0)
			
			if contacts(mouse_pos) and template.clickable and game.get_blueprint() == null:
				
				game.set_tooltip("Click to boost!",0.033)
				
				if Input.is_action_just_pressed("Place Structure"):
					game.change_HP(template.HP_output)
					game.change_money(template.money_output)
					game.change_HP(template.food_output)
			
			var best_rate = delta
			
			if template.HP_input != 0.0:
				best_rate = min(best_rate,game.get_HP()/template.HP_input)
			
			if template.money_input != 0.0:
				best_rate = min(best_rate,game.get_money()/template.money_input)
			
			if template.food_input != 0.0:
				best_rate = min(best_rate,game.get_food()/template.food_input)
			
			
			
			game.change_HP((template.HP_output-template.HP_input) * best_rate)
			
			game.change_money((template.money_output-template.money_input) * best_rate)
				
			game.change_food((template.food_output-template.food_input) * best_rate)
			
			



func recoloration(input: Color) -> void:
	var par = get_parent()
	if par is CanvasGroup:
		if par.material is ShaderMaterial:
			#print("recolor")
			par.material.set_shader_parameter("color_reshading",input)
