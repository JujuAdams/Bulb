attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec2 v_vPosition;

void main()
{
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] *vec4(in_Position.xyz, 1.0);
    gl_Position.z = 0.5;
    
    v_vColour   = in_Colour;
    v_vTexcoord = in_TextureCoord;
    v_vPosition = gl_Position.xy;
}