attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4 u_vUV;
uniform vec4 u_vLightPosition;
uniform vec4 u_vLightColour;
uniform vec3 u_vTranslate;

void main() {
	
	vec4 pos = vec4( in_Position.xyz, 1.0 );
	if ( in_Colour.a == 0.0 ) {
		pos.xy = floor( pos.xy );
		gl_Position = gm_Matrices[MATRIX_PROJECTION]*gm_Matrices[MATRIX_VIEW]*pos;
		gl_Position.z = 0.0;
		v_vColour = in_Colour;
	} else {
		pos = gm_Matrices[MATRIX_WORLD]*pos;
		pos.xy = floor( pos.xy );
		gl_Position = gm_Matrices[MATRIX_PROJECTION]*gm_Matrices[MATRIX_VIEW]*pos;
		gl_Position.zw = vec2( 1.0 );
		v_vColour = in_Colour*u_vLightColour;
	}
	
	gl_Position.xyz += u_vTranslate * gl_Position.w;
	
    v_vTexcoord = u_vUV.xy + u_vUV.zw*in_TextureCoord;
	
}