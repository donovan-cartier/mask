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
	// DEBUG: Just output the texture directly to see if viewport is working
	vec4 color = texture(TEXTURE, UV);
	COLOR = color;

	// TODO: Re-add pixelation and dithering once viewport rendering is confirmed working
}
