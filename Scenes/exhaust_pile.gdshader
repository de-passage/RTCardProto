shader_type canvas_item;



void fragment() {
	float d = length(UV - .5);
	COLOR = vec4(d,d,d, 1.);
}
