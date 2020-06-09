/* Simple triplanar projection shader with units in world space. */
/* Color of the texture background can be set. */

shader_type spatial;

uniform sampler2D tex;
uniform vec4 color : hint_color;

varying vec3 weights;
varying vec3 world_pos;

void vertex() {
	world_pos = mat3(WORLD_MATRIX) * VERTEX;
	weights = abs(NORMAL);
}

void fragment() {
	vec2 uv_front = world_pos.xy;
	vec2 uv_side = -world_pos.zy;
	vec2 uv_top = world_pos.xz;
	
	uv_front.y *= -1.0f;
	
	vec4 col_front = texture(tex, uv_front);
	vec4 col_side = texture(tex, uv_side);
	vec4 col_top = texture(tex, uv_top);
	
	col_side *= weights.x;
	col_top *= weights.y;
	col_front *= weights.z;
	
	vec4 col = col_front + col_side + col_top;
	col = col.a * col + (1.0f - col.a) * color;
	
	ALBEDO = col.rgb;
}