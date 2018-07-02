shader_type spatial;
render_mode shadows_disabled;
uniform float rim = 0.25;
uniform float rim_tint = 0.5;
uniform sampler2D color_ramp : hint_black_albedo;
uniform sampler2D albedo : hint_albedo;
uniform float specular;
uniform float roughness = 1.0;
uniform bool vertical = true;
uniform vec4 item_color : hint_color; 
uniform bool disable_lighting = false;
uniform bool enable_colorization = false;
uniform sampler2D color_mask;

void light() {
	if (disable_lighting) {
		DIFFUSE_LIGHT = ALBEDO;
		return;
	}
	
	float litness = dot(LIGHT,NORMAL);
	litness = clamp(litness, 0.01,1.0);
	litness = 1.0-litness; // Inverted because toon maps are inverted too
	float ramp_position_x = 0.0;
	
	// Color ramp tinting
	vec3 ramp_point = vec3(0.0);
	ramp_point = texture(color_ramp, vec2(0.5,litness)).rgb;
	
	float NdotL = 1.0; // To avoid gradients... right?
	float NdotV = dot(NORMAL, VIEW);
	float cNdotV = max(NdotV, 0.0);
	float diffuse_brdf_NL = smoothstep(-ROUGHNESS,max(ROUGHNESS,0.01),NdotL);
	DIFFUSE_LIGHT += ramp_point*0.8*ATTENUATION*ALBEDO*diffuse_brdf_NL*(LIGHT_COLOR*0.3);
	
	float rim_light = pow(max(0.0,1.0-cNdotV), max(0.0,(1.0-0.7)*16.0));
	DIFFUSE_LIGHT += rim_light * rim * mix(vec3(1.0),ALBEDO,rim_tint) * LIGHT_COLOR;
	// Specular stuff
	vec3 R = normalize(-reflect(LIGHT,NORMAL));
	float RdotV = dot(R,VIEW);
	float mid = 1.0-ROUGHNESS;
	mid*=mid;
	float intensity = smoothstep(mid-ROUGHNESS*0.5, mid+ROUGHNESS*0.5, RdotV) * mid;
	DIFFUSE_LIGHT += LIGHT_COLOR * intensity * specular * ATTENUATION; // write to diffuse_light, as in toon shading you generally want no reflection
}
void fragment() {
	ROUGHNESS = roughness;
	SPECULAR=0.0;
	vec3 albedo_tex = texture(albedo,UV).rgb;
	vec3 color_mask_tex = texture(color_mask,UV).rgb;
	if (enable_colorization == true) {
		vec3 texture_base = vec3((albedo_tex.r+albedo_tex.g+albedo_tex.b)/3.0); // Greyscale texture
		
		vec3 colorized = item_color.rgb * (texture_base + item_color.rgb * 0.5); // Texture colorized with item color
		float albedo_value = 1.0-color_mask_tex.r;
		float colorized_value = 1.0-albedo_value;
		colorized = colorized*colorized_value + albedo_tex*albedo_value; // Final texture
		ALBEDO = colorized;
	}
	else {
		ALBEDO = albedo_tex.rgb;
	}
	//ALBEDO = albedo_tex.rgb;
	TRANSMISSION = vec3(0.5);
}
