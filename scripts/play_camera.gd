extends Camera2D

@export var speed = 900.0

var bounds: Rect2 = Rect2(-1000,-1000,2000,2000)



func _process(_delta: float) -> void:
	var movement = false#Input.get_vector("Move Left","Move Right","Move Up","Move Down")
	
	if movement:
		#var axis = movement.round()
		#movement *= Vector2(1-axis,axis)
		#movement = movement.normalized()
		
		#position += movement * speed * delta
		
		pass
	
	var edges = Vector2(get_window().size)
	
	var temp = bounds
	
	
	temp.position += (temp.size/2.0).min(edges/2.0)
	temp.size -= (temp.size).min(edges)
	
	position = position.clamp(temp.position,temp.end)
