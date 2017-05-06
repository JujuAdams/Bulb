attribute vec3 in_Position;

void main() {
	
	vec4 pos = vec4( in_Position.xyz, 1.0 );
	//pos.xy = floor( pos.xy );
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION]*pos;
	
}