class_name AnimationManager
extends AnimatedSprite2D


@export var delta_offset: float = 0.0
var auto_animate: bool = false

func _process(_delta: float) -> void:
	var time: float = Time.get_unix_time_from_system()
	if auto_animate:
		game_animation(time)


func game_animation(time: float) -> void:
	var my_time = time + delta_offset
	
	var frame_total: int = sprite_frames.get_frame_count(animation)
	var duration: float = sprite_frames.get_animation_speed(animation)
	frame = clamp(floori(modulus(my_time,frame_total / duration)*duration),0,frame_total)
	
	for child in get_children():
		if child is AnimationManager:
			child.game_animation(my_time)
	


func start() -> void:
	auto_animate = true


func finish() -> void:
	auto_animate = false


static func modulus(source: float, mod: float) -> float:
	var sub = (1.0 * source)/(1.0 * mod) # -10, 3 -> -3.333
	var ans = source - (mod * floor(sub)) # -10, 3, -3.333 -> 2
	return ans
