shader_type spatial;
render_mode blend_add, depth_draw_never, cull_disabled, unshaded;

// Particle color (will be multiplied by gradient)
uniform vec4 particle_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Gradient softness control (smaller = softer edges)
uniform float softness : hint_range(0.1, 2.0) = 0.8;

// Glow intensity for luminous particles (embers)
uniform float glow_strength : hint_range(0.0, 3.0) = 0.0;

void vertex() {
	// Billboard effect - rotate quad towards camera
	mat4 mat_world = mat4(
		normalize(INV_VIEW_MATRIX[0]),
		normalize(INV_VIEW_MATRIX[1]),
		normalize(INV_VIEW_MATRIX[2]),
		MODEL_MATRIX[3]
	);
	mat_world = mat_world * mat4(
		vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
		vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
		vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
		vec4(0.0, 0.0, 0.0, 1.0)
	);
	MODELVIEW_MATRIX = VIEW_MATRIX * mat_world;
}

void fragment() {
	// Centered UV coordinates (-0.5 to 0.5)
	vec2 centered_uv = UV - vec2(0.5);

	// Distance from center
	float dist = length(centered_uv) * 2.0;

	// Smooth radial gradient
	float alpha = 1.0 - smoothstep(0.0, softness, dist);
	alpha = pow(alpha, 2.0); // Make gradient more pronounced

	// Apply color and alpha
	ALBEDO = particle_color.rgb;
	ALPHA = alpha * particle_color.a;

	// Glow for luminous particles (embers)
	if (glow_strength > 0.0) {
		EMISSION = particle_color.rgb * glow_strength * alpha;
	}
}
