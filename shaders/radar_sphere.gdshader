shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, unshaded;

// Couleur de base des lignes (contrôlée par l'époque)
uniform vec3 line_color : source_color = vec3(0.0, 1.0, 0.0);
// Intensité du glow (0 = pas de glow, >0 = glow via emission)
uniform float glow_strength : hint_range(0.0, 5.0) = 0.0;
// Épaisseur des lignes
uniform float line_thickness : hint_range(0.001, 0.5) = 0.02;
// Nombre de lignes de latitude
uniform int latitude_lines : hint_range(4, 24) = 12;
// Nombre de lignes de longitude
uniform int longitude_lines : hint_range(4, 24) = 16;
// Alpha de base
uniform float base_alpha : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	// Coordonnées sphériques via UV
	float lat = UV.y * PI;
	float lon = UV.x * TAU;

	// Distance aux lignes de grille
	float lat_step = PI / float(latitude_lines);
	float lon_step = TAU / float(longitude_lines);

	float lat_dist = abs(mod(lat + lat_step * 0.5, lat_step) - lat_step * 0.5) / lat_step;
	float lon_dist = abs(mod(lon + lon_step * 0.5, lon_step) - lon_step * 0.5) / lon_step;

	float grid_dist = min(lat_dist, lon_dist);

	// Masque de ligne net (sans glow)
	float line_mask = 1.0 - smoothstep(0.0, line_thickness, grid_dist);

	// Discard pixels hors des lignes pour transparence nette
	if (line_mask < 0.01) {
		discard;
	}

	ALBEDO = line_color;
	ALPHA = line_mask * base_alpha;

	// Glow optionnel via emission
	if (glow_strength > 0.0) {
		EMISSION = line_color * glow_strength;
	}
}
