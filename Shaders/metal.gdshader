shader_type canvas_item;

uniform sampler2D noise;
uniform sampler2D colors;

void fragment() {
	vec4 p = texture(TEXTURE, UV);
	vec4 n = texture(noise, UV);
	vec4 c = texture(colors, vec2(n.r,n.r));
	
	COLOR.rgba = p * c;
}
