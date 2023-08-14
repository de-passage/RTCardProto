shader_type canvas_item;

uniform sampler2D noise;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_nearest, repeat_disable; 
uniform vec3 target_color: source_color;
uniform float diffusion: hint_range(0.0, 10.0, 0.1);

void fragment() {
	vec4 screen = texture(SCREEN_TEXTURE, SCREEN_UV);
	if (screen == vec4(1.,1.,1.,1.)) {
		float n = texture(noise, UV).r * diffusion;
		COLOR.a = 1.;
		COLOR.rgb = vec3(
			mix(target_color.r, 1., n),
			mix(target_color.g, 1., n), 
			mix(target_color.b, 1., n));
	} else {
		COLOR = screen;
	}
}
