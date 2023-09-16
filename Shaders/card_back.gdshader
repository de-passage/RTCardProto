shader_type canvas_item;

void fragment() {
	float t = sin(TIME) / 4. +.5;
	vec3 col = texture(TEXTURE, UV).rgb;
	float gs = (col.r + col.g + col.b) / 3.;
	COLOR = vec4(gs * vec2(t), 0., 1.);
}
