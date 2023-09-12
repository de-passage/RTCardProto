shader_type canvas_item;

uniform vec3 color: source_color;

void fragment() {
	float d = length(UV - .5);
	COLOR = vec4(color, 1. - clamp(d * 2., 0., 1.));
}
