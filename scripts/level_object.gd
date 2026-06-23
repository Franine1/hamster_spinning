class_name LevelObject
extends StaticBody2D

##audio on click
@onready var click_sound = preload("res://sfx/hamster factory sounds/squeak.wav")

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
var click_player: AudioStreamPlayer

func _ready() -> void:

	sprite = Sprite2D.new()
	add_child(sprite)
	##audio click
	click_player = AudioStreamPlayer.new()
	click_player.stream = click_sound
	add_child(click_player)
	##audio click
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

func contacts(pos: Vector2) -> bool:
	var space: Rect2 = Rect2(global_position - placement_offset,placement_offset * 2)
	
	return space.has_point(pos)

func click_reaction() -> void:
	pass


func _process(delta: float) -> void:
	var game: GameData = GameData.get_game()
	
	var mouse_pos: Vector2 = get_global_mouse_position()
	
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
				place(mouse_pos)
				
				
				if !test_move(transform,Vector2.ZERO,null,0.08,true):
					if Input.is_action_just_pressed("Place Structure"):
						#placement_mode = mode.PLACED
						
						var temp = self.duplicate()
						temp.placement_mode = mode.PLACED
						add_sibling(temp)
						game.set_blueprint()
						game.add_unlocks(template)
						#print("placed")
				else:
					pass
			
			
			
		mode.PLACED:
			visible = true
			collision_layer = 1
			collision_mask = 0
			z_index = 19
			modulate = Color(1.0,1.0,1.0,1.0)
			
			if contacts(mouse_pos) and template.clickable and game.get_blueprint() == null:
				
				game.set_tooltip("Click to boost!",0.033)
				
				if Input.is_action_just_pressed("Place Structure"):
					##audio
					click_player.volume_db = -10
					##click_player.volume_db = randf_range(-1.0, 1.0)
					click_player.pitch_scale = randf_range(0.9, 1.1)
					click_player.play()
					#audio
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
			
			
