shader_type canvas_item;

uniform vec4 original_color[10]: source_color;
uniform vec4 replacement_color[10]: source_color;

bool close_enough(vec4 first, vec4 second) {
	return distance(first,second) < 0.005;
}

void vertex() {
	
}

void fragment() {
	vec4 c = texture(TEXTURE,UV);
	
	for (int i = 0; i < original_color.length(); i++) {
		if (close_enough(c,original_color[i])) {
			c = replacement_color[i];
			break;
		}
	}
	
	COLOR = c;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
