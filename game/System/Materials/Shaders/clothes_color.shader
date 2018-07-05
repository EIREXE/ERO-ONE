shader_type spatial;

uniform float fresnel;
uniform float fresnel_tint;
uniform float frensnel_strength;
uniform float fresnel_diffcont;

uniform float transmission;
uniform sampler2D albedo : hint_albedo;

float saturate(float x)
{
  return max(0, min(1, x));
}

float SmoothnessToPerceptualRoughness(float smoothness)
{
    return (1.0 - smoothness);
}

// Calculate direct lighting
vec3 ToonBRDF_Direct(vec3 specColor, float rlPow4, float smoothness, float nl)
{
	float LUT_RANGE = 16.0; // must match range in NHxRoughness() function in GeneratedTextures.cpp
						   // Lookup texture to save instructions
	float specular = 0.0;
	float specularSteps = max(((1.0 - smoothness) * 4.0), 0.01); // Calculate specular step count based on roughness
	specular = round(specular * specularSteps) / specularSteps; // Step the specular term
	return specular * nl * specColor; // Return colored specular multiplied by NdotL 
}

vec3 ToonBRDF_Diffuse(vec3 diffColor, vec3 lightDir, vec3 normal, vec3 lightColor)
{
	lightDir = normalize(lightDir); // Normalize light direction
	vec3 diffuse = vec3(saturate((dot(normal, lightDir) + transmission) / ((1.0 + transmission) * (1.0 + transmission)))); // Wrap diffuse based on transmission
	diffuse = min((round(diffuse * 2.0) / 2.0) + transmission, vec3(1.0));
	//diffuse = min(step(0.01, diffuse) + (_Transmission), 1); // Step the diffuse term and rebalance zero area to simulate transmission
	return diffuse * lightColor; // Return diffuse multiplied by light color
}

void light() {
	vec3 reflDir = reflect(VIEW, NORMAL);
	float nl = saturate(dot(NORMAL, LIGHT));
	float nv = saturate(dot(NORMAL, VIEW));
	vec2 rlPow4AndFresnelTerm = pow(vec2(dot(reflDir, LIGHT), 1.0 - nv), vec2(4.0));
	float rlPow4 = rlPow4AndFresnelTerm.x;
	float fresnelTerm = rlPow4AndFresnelTerm.y;
	vec3 diffuse = ToonBRDF_Diffuse(ALBEDO, LIGHT, NORMAL, LIGHT_COLOR);

	DIFFUSE_LIGHT += (ALBEDO) * diffuse;

}

void fragment() {
	ALBEDO = texture(albedo, UV).rgb;
}