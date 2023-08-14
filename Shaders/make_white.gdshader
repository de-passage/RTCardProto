shader_type canvas_item;

void fragment() {
	float alpha = texture(TEXTURE, UV).a;
	COLOR.a = alpha;
	COLOR.rgb = vec3(1.0,1.0,1.0);
}
