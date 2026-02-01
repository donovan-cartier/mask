shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled;

uniform vec4 water_color : source_color = vec4(0.1, 0.3, 0.5, 0.8);
uniform vec4 foam_color : source_color = vec4(1.0, 1.0, 1.0, 0.5);
uniform float wave_speed : hint_range(0.1, 5.0) = 1.0;
uniform float wave_strength : hint_range(0.01, 0.5) = 0.05;
uniform float wave_frequency : hint_range(0.5, 10.0) = 2.0;
uniform float fresnel_power : hint_range(0.5, 5.0) = 2.0;

void vertex() {
	// Animate waves
	float wave1 = sin(VERTEX.x * wave_frequency + TIME * wave_speed) * wave_strength;
	float wave2 = cos(VERTEX.z * wave_frequency * 0.8 + TIME * wave_speed * 1.2) * wave_strength;
	VERTEX.y += wave1 + wave2;

	// Calculate normal from wave derivatives
	float dx = cos(VERTEX.x * wave_frequency + TIME * wave_speed) * wave_strength * wave_frequency;
	float dz = -sin(VERTEX.z * wave_frequency * 0.8 + TIME * wave_speed * 1.2) * wave_strength * wave_frequency * 0.8;
	NORMAL = normalize(vec3(-dx, 1.0, -dz));
}

void fragment() {
	// Fresnel effect for edge highlighting
	float fresnel = pow(1.0 - dot(NORMAL, VIEW), fresnel_power);

	// Mix water color with foam based on fresnel
	vec3 final_color = mix(water_color.rgb, foam_color.rgb, fresnel * 0.3);

	ALBEDO = final_color;
	ALPHA = water_color.a + fresnel * 0.2;
	ROUGHNESS = 0.05;
	METALLIC = 0.2;
	SPECULAR = 0.8;
}
