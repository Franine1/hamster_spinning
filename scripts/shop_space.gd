class_name ShopSpace
extends ItemList



@export var allowed_structures: Array[Structure] = []
##audio
var hover_player: AudioStreamPlayer
var click_player:AudioStreamPlayer
var last_hovered_id: int = -1


var linked_list: Dictionary[int,int]

var refresh_time: float = 0.0

func _ready() -> void:
	display_items()
	icon_mode = ItemList.ICON_MODE_TOP
	
	##audio
	hover_player = AudioStreamPlayer.new()
	hover_player.stream = preload("res://sfx/satellite sounds/blipSelect.wav")
	hover_player.volume_db = -2
	add_child(hover_player)
	
	click_player = AudioStreamPlayer.new()
	click_player.stream = preload("res://sfx/satellite sounds/clicksound.wav")
	click_player.volume_db = -2
	add_child(click_player)

func recolor_image(vp: SubViewport, index: int) -> void:
	await RenderingServer.frame_post_draw
	var img: ImageTexture = ImageTexture.create_from_image(vp.get_texture().get_image())
	set_item_icon(index,img)
	remove_child(vp)
	vp.queue_free()

func display_items() -> void:
	item_count = 0
	
	deselect_all()
	
	for i in allowed_structures.size():
		var struct: Structure = allowed_structures[i]
		var img: ImageTexture = ImageTexture.create_from_image(struct.image.get_image())
		img.set_size_override(Vector2(struct.size))
		
		var indx: int = add_item(struct.description,img,true)
		
		if struct.recolor != null:
			var temp: Sprite2D = Sprite2D.new()
			temp.texture = img
			temp.material = struct.recolor
			var vp: SubViewport = SubViewport.new()
			vp.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
			vp.transparent_bg = true
			vp.render_target_update_mode = SubViewport.UPDATE_ONCE
			vp.size = img.get_size()
			vp.add_child(temp)
			temp.position += img.get_size()/2.0
			add_child(vp)
			
			recolor_image(vp,indx)
		
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
	
	var id = get_item_at_position(get_global_mouse_position() - trn.origin,true)
	
	if id != -1 and get_viewport().handle_input_locally:
		game.set_tooltip(allowed_structures[linked_list[id]].tooltip(),0.1,"shop_item")
		##audio
		if id != last_hovered_id and !is_item_disabled(id):
			hover_player.volume_db = -10.0
			hover_player.pitch_scale = randf_range(0.95, 1.05)
			hover_player.play()
			last_hovered_id = id
		
		if !is_selected(id):
			deselect_all()
		select(id)
		#print(tr)
		
		if Input.is_action_just_pressed("Place Structure"):
			##audio
			
			
			var bp: Structure = allowed_structures[linked_list[id]]
			var cost: Vector3 = bp.cost()
			if Structure.affordable(cost):
				click_player.volume_db = -10.0
				click_player.pitch_scale = randf_range(0.9, 1.1)
				click_player.play()
				
				if bp.purchase_hints.has("win"):
					erase_item(id)
					Structure.expend(cost)
					game.declare_victory()
				else:
					Structure.expend(cost)
					game.set_blueprint(bp)
			else:
				# cannot afford structure
				if bp.error_sound:
					var p := AudioStreamPlayer.new()
					p.stream = bp.error_sound
					p.volume_db = -6
					p.pitch_scale = randf_range(0.95, 1.05)
					add_child(p)
					p.play()
					p.connect("finished", p.queue_free)
	else:
		last_hovered_id = -1
		deselect_all()
	
	#print(get_tooltip(get_local_mouse_position()))


func erase_item(index: int) -> void:
	remove_item(index)
	linked_list.erase(index)
