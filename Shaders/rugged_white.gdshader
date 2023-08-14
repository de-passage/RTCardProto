shader_type canvas_item;

uniform sampler2D noise; 
uniform vec2 offset;

void fragment() {
	float n = texture(noise, UV + offset).r;
	COLOR.a = texture(TEXTURE, UV).a * n * 2.;
	COLOR.rgb = vec3(1, 1, 1);
}
