shader_type spatial;
render_mode blend_add, depth_draw_never, cull_disabled, unshaded;

// Couleur de la particule (sera multiplié par le gradient)
uniform vec4 particle_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Contrôle de la douceur du gradient (plus petit = bords plus doux)
uniform float softness : hint_range(0.1, 2.0) = 0.8;

// Intensité du glow pour les particules lumineuses (embers)
uniform float glow_strength : hint_range(0.0, 3.0) = 0.0;

void vertex() {
	// Billboard effect - faire tourner le quad vers la caméra
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
	// Coordonnées UV centrées (-0.5 à 0.5)
	vec2 centered_uv = UV - vec2(0.5);

	// Distance du centre
	float dist = length(centered_uv) * 2.0;

	// Gradient radial lisse
	float alpha = 1.0 - smoothstep(0.0, softness, dist);
	alpha = pow(alpha, 2.0); // Rendre le gradient plus prononcé

	// Appliquer la couleur et l'alpha
	ALBEDO = particle_color.rgb;
	ALPHA = alpha * particle_color.a;

	// Glow pour les particules lumineuses (embers)
	if (glow_strength > 0.0) {
		EMISSION = particle_color.rgb * glow_strength * alpha;
	}
}
