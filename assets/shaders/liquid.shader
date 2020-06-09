/* Shader for the liquid itself. */

shader_type spatial;

render_mode cull_back, shadows_disabled;

uniform vec2 coeff; /* Coefficients of the linear function for the surface. */
uniform vec2 vel; /* Rate of change of the coefficients. */

uniform float fill_amount : hint_range(0.0f, 1.0f);

uniform float height = 0.32f;
uniform float width = 0.1f;
uniform float glass_thickness = 0.01f;

uniform float wave_intensity = 0.05f;
uniform vec4 liquid_color : hint_color;
uniform vec4 glow_color : hint_color;
uniform sampler2D waves_noise;

uniform sampler2D bubbles_tex;

varying vec3 pos;
varying vec3 weights;
varying float liquid_line;

float lerp(float a, float b, float t) {
	return b * t + a * (1.0f - t);
}

void vertex() {
	/* Move vertices inwards to simulate glass thickness. */
	VERTEX -= glass_thickness * NORMAL;
	
	/* Position inside container rotated to world. */
	pos = mat3(WORLD_MATRIX)*VERTEX;
	
	/* Lerp between height and width depending on world orientation of z axis. */
	float d = dot(vec3(WORLD_MATRIX[0][1], WORLD_MATRIX[1][1], WORLD_MATRIX[2][1]), vec3(0.0f, 1.0f, 0.0f));
	float m = lerp(width, height, abs(d));
	
	/* Set liquid line to fill amount, add noise waves and incline. */
	/* This could also be moved to the fragment function as-is for finder results. */
	liquid_line = (fill_amount - 0.5f) * m
				  + wave_intensity * length(coeff) * (texture(waves_noise, 2.0*pos.xz + 0.5*TIME * vec2(1.0, 1.0)).r - 0.5f
											  	      + texture(waves_noise, 2.0*pos.xz - 0.5*TIME * vec2(1.0, 1.0)).g - 0.5f)
				  + dot(pos.xz, coeff);
	
	/* Calculate weights used for triplanar projection of bubble texture. */			
	vec3 normal = mat3(WORLD_MATRIX)*NORMAL;
	weights = normal*normal;
}

void fragment() {
	/* Discard all vertices above the liquid line. */
	if (pos.y > liquid_line) discard;
	else ALBEDO = liquid_color.rgb;
}

void light() {
	/* Liquid "glow" when held against light. */
	float d = dot(-VIEW, LIGHT);
	float dd = d*d;
	if (d > 0.0f) DIFFUSE_LIGHT = dd * glow_color.rgb;
	
	/* Bubbles */
	
	/* First, triplanar map the bubble texture (or at least "diplanar" map it
	 * to the sides.)
	 * Also, distort the bubbles a bit so it looks like they are wavy. */
	vec2 distortion = vec2(0.0f, 0.005f * texture(waves_noise, 10.0f*pos.yx).y - 0.005f);
	vec2 uv_front = pos.yx + distortion;
	vec2 uv_side = pos.yz + distortion;
	vec4 bubbles_front = texture(bubbles_tex, 15.0f*uv_front - TIME * vec2(2.0f, 0.0f));
	vec4 bubbles_side = texture(bubbles_tex, 15.0f*uv_side - TIME * vec2(2.0f, 0.0f));
	vec4 bubbles = weights.z * bubbles_front + weights.x * bubbles_side;
	
	/* Remove bubbles from top and bottom of the liquid. */
	float bubbles_alpha = bubbles.a;
	if (bubbles_alpha != 0.0f) {
		if (pos.y > liquid_line - 0.01f) bubbles_alpha *= (liquid_line - pos.y)/ 0.01f;
		else if (pos.y < -height / 2.0f + 0.02f) bubbles_alpha *= clamp((pos.y + height / 2.0f) / 0.02f, 0.0f, 1.0f);
		/* Bubbles should disappear on the sides and revert color depending on
		 * view angle, resulting in a shadow or glow effect. */
		bubbles_alpha *= d;
		/* Bubbles should only appear when the liquid is in motion. */
		bubbles_alpha *= clamp(length(vel), 0.0f, 1.0f);
	}
	DIFFUSE_LIGHT -= bubbles_alpha * glow_color.rgb;
}