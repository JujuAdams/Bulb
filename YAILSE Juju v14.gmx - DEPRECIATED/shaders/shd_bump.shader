attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec4 v_vColour;
varying vec2 v_vTexcoord;
varying vec2 v_bumpPos;
varying vec2 v_bumpPosLarge;

uniform vec2 u_lightTopLeft;
uniform vec2 u_lightScale;
uniform vec2 u_bumpTopLeft;
uniform vec2 u_bumpSize;
uniform float u_scale;

void main() {
    
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
    
    vec2 normLightPos = ( in_TextureCoord - u_lightTopLeft ) * u_lightScale;
    
    v_bumpPos = u_bumpTopLeft + normLightPos * u_bumpSize;
    v_bumpPosLarge = u_bumpTopLeft + ( u_scale * 0.5 ) + normLightPos * ( u_bumpSize - u_scale );
    
}
//######################_==_YOYO_SHADER_MARKER_==_######################@~varying vec4 v_vColour;
varying vec2 v_vTexcoord;
varying vec2 v_bumpPos;
varying vec2 v_bumpPosLarge;

uniform sampler2D smp_bump;

void main() {
    float dist = max( 0.0, 1.0 - distance( vec2( 0.5, 0.5 ), v_vTexcoord ) * 2.0 );
    gl_FragColor = v_vColour * vec4( dist, dist, dist, 1 ) * vec4( 1.0 + 0.5 * texture2D( smp_bump, v_bumpPos ).rgb - 0.5 * texture2D( smp_bump, v_bumpPosLarge ).rgb, 1.0 );
}

