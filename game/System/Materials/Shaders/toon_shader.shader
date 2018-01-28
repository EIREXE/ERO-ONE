shader_type spatial;
render_mode diffuse_toon, specular_toon;

uniform sampler2D color_ramp : hint_black_albedo;
uniform sampler2D albedo : hint_albedo;
uniform float specular;
uniform float roughness = 1.0;
uniform bool vertical = true;
/*
void vertex() {
	litness = 1.0;
}*/

void light() {
	float litness = dot(LIGHT,NORMAL);
	litness = clamp(litness, 0.1,0.9);
	litness = 1.0-litness; // Inverted because toon maps are inverted too
	float ramp_position_x = 0.0;
	vec3 ramp_point = vec3(0.0);
	if (vertical) {
		ramp_point = texture(color_ramp, vec2(0.5,litness)).rgb;
	}
	else {
		ramp_point = texture(color_ramp, vec2(litness,0.5)).rgb;
	}
	float NdotL = dot(NORMAL,LIGHT);
	float diffuse_brdf_NL = smoothstep(-ROUGHNESS,max(ROUGHNESS,0.01),NdotL);
	DIFFUSE_LIGHT += ramp_point*LIGHT_COLOR*ATTENUATION*ALBEDO*mix(vec3(diffuse_brdf_NL), vec3(3.14159265359), vec3(0.40));
	vec3 R = normalize(-reflect(LIGHT,NORMAL));
	float RdotV = dot(R,VIEW);
	float mid = 1.0-ROUGHNESS;
	mid*=mid;
	float intensity = smoothstep(mid-ROUGHNESS*0.5, mid+ROUGHNESS*0.5, RdotV) * mid;
	DIFFUSE_LIGHT += LIGHT_COLOR * intensity * specular * ATTENUATION; // write to diffuse_light, as in toon shading you generally want no reflection
}
void fragment() {
	ROUGHNESS = roughness;
	SPECULAR=1.0;
	//float ramp_position_x = float(textureSize(color_ramp,0).y)*litness;
	//vec4 ramp_point = texture(color_ramp, vec2(0.0,litness));
	vec3 albedo_tex = texture(albedo,UV).rgb;
	ALBEDO = albedo_tex;
	TRANSMISSION = vec3(0.5);
}