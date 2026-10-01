shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.72, 0.28, 1.0, 1.0);
uniform float glow_strength : hint_range(0.0, 1.0) = 0.0;
uniform float glow_radius : hint_range(1.0, 16.0) = 10.0;

void fragment() {
	vec4 button_color = texture(TEXTURE, UV) * COLOR;
	float surrounding_alpha = 0.0;

	for (int x = -2; x <= 2; x++) {
		for (int y = -2; y <= 2; y++) {
			if (x == 0 && y == 0) {
				continue;
			}
			vec2 offset = vec2(float(x), float(y)) * TEXTURE_PIXEL_SIZE * glow_radius * 0.5;
			surrounding_alpha = max(surrounding_alpha, texture(TEXTURE, UV + offset).a);
		}
	}

	float glow_alpha = max(surrounding_alpha - button_color.a, 0.0) * glow_strength;
	COLOR = vec4(button_color.rgb + glow_color.rgb * glow_alpha, max(button_color.a, glow_alpha * glow_color.a));
}