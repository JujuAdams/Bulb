precision highp float;

#define MAX_LENGTH 50.0

attribute vec3 in_Position;
attribute vec3 in_Normal;

uniform vec2  u_vLight;
uniform float u_fNormalCoeff;

void main()
{
    vec2 delta = in_Position.xy - u_vLight;
    float finalLength = MAX_LENGTH*step(u_fNormalCoeff*dot(delta, in_Normal.xy), 0.0);
    
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION]*vec4(in_Position.xy + in_Position.z*finalLength*delta, 0.0, 1.0);
    gl_Position.z = 0.0;
}