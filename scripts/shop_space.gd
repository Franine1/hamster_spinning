class_name ShopSpace
extends ItemList



@export var allowed_structures: Array[Structure] = []

var linked_list: Dictionary[int,int]

var refresh_time: float = 0.0

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
		
		#set_item_tooltip(indx,struct.tooltip())
		#set_item_tooltip_enabled(indx,true)
		
		linked_list[indx] = i
	
	refresh_display()


func refresh_display() -> void:
	var game: GameData = GameData.get_game()
	
	for i in linked_list.keys():
		
		var struct: Structure = allowed_structures[linked_list[i]]
		
		set_item_disabled(i,!game.is_unlocked(struct))
		
		#set_item


func _process(_delta: float) -> void:
	refresh_time += _delta
	if refresh_time >= 0.5:
		refresh_time -= 0.5
		refresh_display()
	
	var game: GameData = GameData.get_game()
	
	var trn = get_global_transform()
	
	var id = get_item_at_position(get_global_mouse_position() + (Vector2(get_window().size) * Vector2(1.0,0.0)) - trn.origin,true)
	
	if id != -1 and get_viewport().handle_input_locally:
		game.set_tooltip(allowed_structures[linked_list[id]].tooltip(),0.1)
		select(id)
		#print(tr)
		
		if Input.is_action_just_pressed("Place Structure"):
			var bp: Structure = allowed_structures[linked_list[id]]
			var cost: Vector3 = bp.cost()
			if Structure.affordable(cost):
				Structure.expend(cost)
				game.set_blueprint(bp)
			else:
				# cannot afford structure
				pass
	else:
		deselect_all()
	
	#print(get_tooltip(get_local_mouse_position()))
