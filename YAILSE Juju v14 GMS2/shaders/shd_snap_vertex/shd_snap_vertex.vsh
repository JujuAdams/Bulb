attribute vec3 in_Position;
attribute vec4 in_Colour;

varying vec4 v_vColour;

void main() {
	vec4 pos = vec4( in_Position.xyz, 1.0 );
	pos.xy = floor( pos.xy );
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * pos;
    v_vColour = in_Colour;
}
