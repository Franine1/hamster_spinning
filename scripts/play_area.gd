class_name PlayArea
extends TileMapLayer


@export var bounds: Rect2i = Rect2i(-18,-9,36,18)
@onready var camera: Camera2D = %Camera2D
@onready var object_placer: LevelObject = %object_placer


func _ready() -> void:
	reset(false)
	



func reset(erase_tiles: bool = true) -> void:
	
	if erase_tiles:
		clear()
		var origin = bounds.position
		for i in bounds.size.x:
			for j in bounds.size.y:
				set_cell(origin+Vector2i(i,j),0,Vector2i(0,0))
	
	var temp = Rect2(bounds)
	temp.position *= 32.0
	temp.size *= 32.0
	camera.bounds = temp


func _process(_delta: float) -> void:
	
	var game: GameData = GameData.get_game()
	var bp: Structure = game.get_blueprint()
	
	
	if object_placer.template != bp:
		var send: Array[Node2D] = []
		
		if bp != null:
			if bp.tier == 0:
				for child in get_children():
					if child is PlacementPoint:
						if child.accepts(bp):
							send.append(child)
			else:
				for child in get_children():
					if child is LevelObject:
						if child.template != null:
							if (child.template.tier+1) == bp.tier and child.template.accepts(bp):
								send.append(child)
		
		object_placer.snap_positions = send
		object_placer.refresh(bp)
