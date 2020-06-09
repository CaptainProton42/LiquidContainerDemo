/* Shader for the container glass itself. Renders behind the liquid. */

shader_type spatial;

/* Cull all front facing faces. */
render_mode cull_front;

uniform vec4 glass_color : hint_color;
uniform vec4 glint_color : hint_color;

void fragment() {
	ALBEDO = glass_color.rgb;
	NORMAL = -NORMAL; // Invert normals of back facing faces.
}

/* Simulates light shining throught the back of the bottle. */
void light() {
	float d = dot(NORMAL, LIGHT);
	float dd = d*d; // In my opinion using this looks a bit better.
	if (d > 0.0f) DIFFUSE_LIGHT += dd * ATTENUATION * glint_color.rgb;
}