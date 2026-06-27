class_name AnimationManager
extends AnimatedSprite2D


@export var delta_offset: float = 0.0
@export var alt_animation: String = ""
var auto_animate: bool = false
var def_animation: String = ""


func _ready() -> void:
	def_animation = animation

func _process(_delta: float) -> void:
	var time: float = Time.get_unix_time_from_system()
	if auto_animate:
		game_animation(time)

func alt_condition(input: bool) -> void:
	if input and sprite_frames.has_animation(alt_animation):
		swap_animation(alt_animation)
	else:
		swap_animation(def_animation)
	
	for child in get_children():
		if child is AnimationManager:
			child.alt_condition(input)

func swap_animation(input: String) -> void:
	if input != animation:
		animation = input

func game_animation(time: float, extra_speed: float = 1.0) -> void:
	var my_time = time + delta_offset
	var spd_bonus: float = extra_speed * speed_scale
	
	var frame_total: int = sprite_frames.get_frame_count(animation)
	var duration: float = sprite_frames.get_animation_speed(animation) * spd_bonus
	frame = clamp(floori(modulus(my_time,frame_total / duration)*duration),0,frame_total)
	
	for child in get_children():
		if child is AnimationManager:
			child.game_animation(my_time,spd_bonus)
	


func start(input: bool = true) -> void:
	auto_animate = input


func finish() -> void:
	auto_animate = false


static func modulus(source: float, mod: float) -> float:
	var sub = (1.0 * source)/(1.0 * mod) # -10, 3 -> -3.333
	var ans = source - (mod * floor(sub)) # -10, 3, -3.333 -> 2
	return ans
