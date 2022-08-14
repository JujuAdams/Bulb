attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec4 v_vPosition;
varying vec2 v_vNormalTexcoord;

void main()
{
    v_vPosition = gm_Matrices[MATRIX_WORLD_VIEW] * vec4(in_Position.xyz, 1.0);
    gl_Position = gm_Matrices[MATRIX_PROJECTION] * v_vPosition;
    
    v_vColour         = in_Colour;
    v_vTexcoord       = in_TextureCoord;
    v_vNormalTexcoord = 0.5 + vec2(0.5, -0.5)*(gl_Position.xy / gl_Position.w);
}
