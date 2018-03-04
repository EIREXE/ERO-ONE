shader_type spatial;
render_mode unshaded;

uniform sampler2D item_base : hint_albedo;
uniform sampler2D color_map : hint_albedo;
uniform vec4 item_color : hint_color;
void fragment() {
	vec3 item_tex = texture(item_base,UV).rgb;
	vec3 color_map_tex = texture(color_map,UV).rgb;
	if (color_map_tex != vec3(0.0)) {
		ALBEDO = item_tex*item_color.rgb;
	} else
	{
		ALBEDO = item_tex;
	}
}