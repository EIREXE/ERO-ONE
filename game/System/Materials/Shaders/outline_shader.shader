shader_type spatial;

render_mode diffuse_toon, specular_toon, cull_front, unshaded;

uniform sampler2D proper_albedo : hint_albedo;
uniform sampler2D color_ramp : hint_black_albedo;

uniform float outline_size : hint_range(0.0,1.0, 0.005);
uniform float brightness_cutoff : hint_range (0.0,1.0);

uniform bool use_solid_color = false;
uniform vec4 solid_color_rgb : hint_color;

uniform float outline_brightness : hint_range(0.0,3.0, 0.1);

void vertex() {
	VERTEX += NORMAL*outline_size;
}

void fragment () {
	vec3 text = texture(proper_albedo, UV).xyz;
	float brightness = (text.r+text.r+text.b+text.g+text.g+text.g)/6.0;
	if (use_solid_color) {
		ALBEDO = solid_color_rgb.xyz;
	} else if (brightness < brightness_cutoff){
		ALBEDO = text*outline_brightness;
	} else {
		ALPHA = 0.0;
	}	
}