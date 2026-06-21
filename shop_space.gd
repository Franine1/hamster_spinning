class_name ShopSpace
extends ItemList



const allowed_structures: Array[Structure] = [
	preload("res://resources/structures/plastic_wheel.tres")
	,preload("res://resources/structures/sawmill.tres")
	,preload("res://resources/structures/feeder.tres")
]

var linked_list: Dictionary[int,int]

func _ready() -> void:
	display_items()
	icon_mode = ItemList.ICON_MODE_TOP

func display_items() -> void:
	item_count = 0
	
	deselect_all()
	
	for i in allowed_structures.size():
		var struct: Structure = allowed_structures[i]
		var img: ImageTexture = ImageTexture.create_from_image(struct.image.get_image())
		img.set_size_override(Vector2(struct.size))
		
		var indx: int = add_item(struct.description,img,true)
		
		set_item_tooltip(indx,struct.tooltip())
		set_item_tooltip_enabled(indx,true)
		
		linked_list[indx] = i

func _process(delta: float) -> void:
	var game: GameData = GameData.get_game()
	
	var id = get_item_at_position(get_global_mouse_position() + (Vector2(get_window().size) * Vector2(1.0,0.0)),true)
	
	if id != -1 and get_viewport().handle_input_locally:
		select(id)
		
		if Input.is_action_just_pressed("Place Structure"):
			game.set_blueprint(allowed_structures[linked_list[id]])
	else:
		deselect_all()
	
	#print(get_tooltip(get_local_mouse_position()))
