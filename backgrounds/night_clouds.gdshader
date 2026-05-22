shader_type canvas_item;

uniform float intensity = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec3 blood_tint = vec3(1.2, 0.2, 0.2);

	tex.rgb = mix(tex.rgb, tex.rgb * blood_tint, intensity);

	COLOR = tex;
}