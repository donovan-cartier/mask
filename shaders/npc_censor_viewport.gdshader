shader_type canvas_item;

// Pixelation and dithering parameters
uniform float pixel_size : hint_range(1.0, 32.0) = 8.0;
uniform float dither_threshold : hint_range(0.0, 1.0) = 0.5;

// Bayer 4x4 dithering matrix
float bayer4x4(vec2 pos) {
	int x = int(mod(pos.x, 4.0));
	int y = int(mod(pos.y, 4.0));

	float bayer[16] = float[16](
		0.0/16.0,  8.0/16.0,  2.0/16.0, 10.0/16.0,
		12.0/16.0, 4.0/16.0, 14.0/16.0,  6.0/16.0,
		3.0/16.0, 11.0/16.0,  1.0/16.0,  9.0/16.0,
		15.0/16.0, 7.0/16.0, 13.0/16.0,  5.0/16.0
	);

	return bayer[y * 4 + x];
}

void fragment() {
	// 1. Apply heavy pixelation
	vec2 pixelated_uv = floor(UV / (pixel_size / 100.0)) * (pixel_size / 100.0);
	vec4 color = texture(TEXTURE, pixelated_uv);

	// 2. Convert to luminance
	float luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));

	// 3. Apply Bayer dithering
	float threshold = bayer4x4(FRAGCOORD.xy) * dither_threshold + (1.0 - dither_threshold) * 0.5;
	float dithered = step(threshold, luma);

	// 4. Pure black or white output
	COLOR = vec4(vec3(dithered), color.a);
}
