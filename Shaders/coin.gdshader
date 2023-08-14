shader_type canvas_item;

uniform vec3 targetColor: source_color; 

void fragment() {
	float height = 1. - UV.y;
	float width = 1. - UV.x;
	
	COLOR.rgb = targetColor.rgb;
	COLOR.b += (height * .2) + (width * .1);
	COLOR.a = texture(TEXTURE, UV).a;
}
