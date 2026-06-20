class_name LevelObject
extends StaticBody2D



@export var template: Structure = null

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
	
	var bounds = input.size
	
	sprite.texture = input.image
	
	sprite.scale = Vector2(bounds) / sprite.texture.get_size()
	
	var temp: RectangleShape2D = RectangleShape2D.new()
	temp.size = Vector2(bounds)
	
	collider.shape = temp
	
	placement_offset = (bounds/32.0).ceil()
	
	placement_offset *= 16.0


func place(pos: Vector2) -> void:
	global_position = (32.0 * (pos/32.0).floor()) + placement_offset

func _process(delta: float) -> void:
	place(get_global_mouse_position())
