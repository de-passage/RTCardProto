shader_type canvas_item;

uniform float flashFrequency;
uniform vec3 color: source_color;
uniform float flashIntensity: hint_range(0.0, 1.0, 0.01);
uniform float flashOffset: hint_range(-1.0, 1.0, 0.1);

float grayscale(vec3 v) {
	return (v.r+v.g+v.b)/3.;
}

vec3 colorize(vec3 source, vec3 target) {
	float gs = grayscale(source);
	return target * gs;
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float alpha = tex.a;
	
	float flash = 1. + (flashOffset + (sin(TAU*TIME*flashFrequency)) / 2. * flashIntensity);
	
	COLOR.rgb = flash * colorize(tex.rgb, color);
	COLOR.a = alpha; 
}
