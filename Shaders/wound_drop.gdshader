shader_type canvas_item;

void fragment() {
	vec4 t = texture(TEXTURE, UV);
	float g = (t.x+t.y+t.z)/3.;
	COLOR = vec4(g*1., 0., 0., t.a);
}
