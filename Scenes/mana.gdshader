shader_type canvas_item;

uniform vec3 color: source_color;

void fragment() {
	float circle = length(UV - .5) * 2.;
	circle = 1. - step(1., circle);
	
	COLOR.rgb = vec3(circle) * color;
	COLOR.a = circle;
}
