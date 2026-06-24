shader_type canvas_item;
//render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec4 color_reshading: source_color = vec4(1.0,1.0,1.0,1.0);

float get_brightness(vec4 input) {
	return (input.r*0.299) + (input.g*0.587) + (input.b*0.114);
}

void fragment() {
	vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);
	
	float brightness = get_brightness(c);
	
	vec4 alter = color_reshading;
	
	float alter_brightness = get_brightness(alter);
	
	alter *= brightness/alter_brightness;
	alter.a = c.a;
	
	if (alter.a > 0.0001) {
		alter.rgb /= alter.a;
	}

	COLOR *= alter;
}