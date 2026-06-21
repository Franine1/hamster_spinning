class_name PlayArea
extends TileMapLayer


@export var bounds: Rect2i = Rect2i(-18,-10,36,20)
@onready var camera: Camera2D = %Camera2D



func _ready() -> void:
	reset()


func reset() -> void:
	clear()
	var origin = bounds.position
	for i in bounds.size.x:
		for j in bounds.size.y:
			set_cell(origin+Vector2i(i,j),0,Vector2i(0,0))
	
	var temp = Rect2(bounds)
	temp.position *= 32.0
	temp.size *= 32.0
	camera.bounds = temp

var time_count: float = 0.0

func _process(delta: float) -> void:
	
	time_count += delta
	
	if time_count >= 0.25:
		
		time_count -= 0.25
		
		print(GameData.get_game().get_HP())
