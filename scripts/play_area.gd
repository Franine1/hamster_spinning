class_name PlayArea
extends TileMapLayer


@export var bounds: Rect2i = Rect2i(-18,-9,36,18)
@onready var camera: Camera2D = %Camera2D
@onready var object_placer: LevelObject = %object_placer


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

func _process(delta: float) -> void:
	var game: GameData = GameData.get_game()
	var bp: Structure = game.get_blueprint()
	
	if object_placer.template != bp:
		object_placer.refresh(bp)
