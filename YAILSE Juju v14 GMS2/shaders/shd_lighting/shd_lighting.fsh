varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	if ( v_vColour.a == 0.0 ) {
		gl_FragColor = vec4( 0.0 );
	} else {
		gl_FragColor = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	}
}