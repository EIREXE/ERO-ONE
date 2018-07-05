shader_type spatial;
render_mode shadows_disabled;
uniform float rim = 0.25;
uniform float rim_tint = 0.5;
uniform sampler2D albedo : hint_albedo;
uniform float specular;
uniform float roughness = 1.0;
uniform bool disable_lighting = false;

uniform vec4 shadow_color : hint_color;

void light() {
	if (disable_lighting) {
		DIFFUSE_LIGHT = ALBEDO;
		return;
	}
	
	float litness = dot(LIGHT,NORMAL);
	litness = clamp(litness, 0.01,1.0);
	litness = 1.0-litness; // Inverted because toon maps are inverted too
	
	vec3 tint = vec3(1.0);
	
	if (litness > 0.5) {
		tint = shadow_color.rgb;
	}
	
	float NdotL = 1.0; // To avoid gradients... right?
	float NdotV = dot(NORMAL, VIEW);
	float cNdotV = max(NdotV, 0.0);
	float diffuse_brdf_NL = smoothstep(-ROUGHNESS,max(ROUGHNESS,0.01),NdotL);
	DIFFUSE_LIGHT += tint*0.8*ATTENUATION*ALBEDO*diffuse_brdf_NL*(LIGHT_COLOR*0.3);
	// rim
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
	vec3 albedo_tex = texture(albedo,UV).rgb;
	ALBEDO = albedo_tex.rgb;
}
