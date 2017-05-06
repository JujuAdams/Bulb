attribute vec3 in_Position;
attribute vec4 in_Colour;

varying vec4 v_vColour;

uniform vec3 u_vTranslate;

void main() {
	
	vec4 pos = vec4( in_Position.xyz, 1.0 );
	//pos.xy = floor( pos.xy );
	gl_Position = gm_Matrices[MATRIX_PROJECTION]*gm_Matrices[MATRIX_VIEW]*pos;
	gl_Position.z = 0.0;
	gl_Position.xyz += u_vTranslate * gl_Position.w;
	
	v_vColour = in_Colour;
	
}