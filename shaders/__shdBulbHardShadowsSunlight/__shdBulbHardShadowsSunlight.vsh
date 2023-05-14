precision highp float;

#define MAX_LENGTH 2000.0

attribute vec3 in_Position;
attribute vec4 in_Texcoord;

uniform vec2  u_vLightVector;
uniform float u_fNormalCoeff;

void main()
{
    vec2 lineNormal = vec2(in_Texcoord.w - in_Texcoord.y, in_Texcoord.x - in_Texcoord.z);
    float finalLength = MAX_LENGTH*step(u_fNormalCoeff*dot(lineNormal, u_vLightVector), 0.0);
    
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION]*vec4(in_Position.xy + in_Position.z*finalLength*u_vLightVector, 0.0, 1.0);
    gl_Position.z = 0.0;
}