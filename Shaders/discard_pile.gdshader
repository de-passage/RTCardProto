shader_type canvas_item;

void fragment() {
	vec4 t = texture(TEXTURE, UV);
	float grayscale = (t.x+t.y+t.z)/3.;
	COLOR = vec4(vec3(grayscale) * (t.rgb / 1.5) , t.a);
}
