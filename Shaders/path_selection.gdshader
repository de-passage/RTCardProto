shader_type canvas_item;

uniform sampler2D noise;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_nearest, repeat_disable; 
uniform vec3 target_color: source_color;
uniform float diffusion: hint_range(0.0, 10.0, 0.1);
uniform float min_grayscale: hint_range(0.0, 1.0, 0.01);

void fragment() {
	vec4 screen = texture(SCREEN_TEXTURE, SCREEN_UV);
	float grayScale = (screen.r + screen.g + screen.b) /3.;
	if (grayScale >= min_grayscale) {
		float n = texture(noise, UV).r * diffusion;

		COLOR.a = 1.;
		COLOR.rgb = vec3(
			mix(target_color.r, screen.r, n),
			mix(target_color.g, screen.g, n), 
			mix(target_color.b, screen.b, n));
	} else {
		COLOR = screen;
	}
}
