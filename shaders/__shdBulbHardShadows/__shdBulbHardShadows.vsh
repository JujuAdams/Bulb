precision highp float;

attribute vec3 in_Position;
attribute vec2 in_TextureCoord;

void main()
{
    gl_Position = gm_Matrices[MATRIX_PROJECTION] * vec4(in_Position.xyz, 1.0);
}