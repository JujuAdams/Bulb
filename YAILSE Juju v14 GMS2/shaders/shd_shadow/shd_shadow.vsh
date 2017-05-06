attribute vec3 in_Position;

void main() {
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION]*vec4( in_Position.xyz, 1.0 );
}