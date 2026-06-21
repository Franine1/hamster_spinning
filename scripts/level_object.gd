class_name LevelObject
extends StaticBody2D



@export var template: Structure = null

@export var placement_mode: mode = mode.WAITING

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
	add_child(sprite)
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
	
	sprite.scale = Vector2(bounds) / sprite.texture.get_size()
	
	var temp: RectangleShape2D = RectangleShape2D.new()
	temp.size = Vector2(bounds) - Vector2(1.0,1.0)
	
	collider.shape = temp
	
	placement_offset = (bounds/32.0).ceil()
	
	placement_offset *= 16.0


func place(pos: Vector2) -> void:
	global_position = (32.0 * (pos/32.0).floor()) + placement_offset

func _process(delta: float) -> void:
	var game: GameData = GameData.get_game()
	
	
	match placement_mode:
		mode.WAITING:
			visible = false
		mode.HOVER:
			if template == null:
				visible = false
				
			else:
			
				visible = true
				collision_layer = 0
				collision_mask = 1
				z_index = 20
				modulate = Color(1.0,1.0,1.0,0.75)
				place(get_global_mouse_position())
				
				
				if !test_move(transform,Vector2.ZERO,null,0.08,true):
					if Input.is_action_just_pressed("Place Structure"):
						#placement_mode = mode.PLACED
						
						var temp = self.duplicate()
						temp.placement_mode = mode.PLACED
						add_sibling(temp)
						game.set_blueprint()
						#print("placed")
				else:
					pass
			
			
			
		mode.PLACED:
			visible = true
			collision_layer = 1
			collision_mask = 0
			z_index = 19
			modulate = Color(1.0,1.0,1.0,1.0)
			
			
			var best_rate = delta
			
			if template.HP_input != 0.0:
				best_rate = min(best_rate,game.get_HP()/template.HP_input)
			
			if template.money_input != 0.0:
				best_rate = min(best_rate,game.get_HP()/template.money_input)
			
			if template.food_input != 0.0:
				best_rate = min(best_rate,game.get_HP()/template.food_input)
			
			
			
			game.change_HP((template.HP_output-template.HP_input) * best_rate)
			
			game.change_money((template.money_output-template.money_input) * best_rate)
				
			game.change_food((template.food_output-template.food_input) * best_rate)
			
			
