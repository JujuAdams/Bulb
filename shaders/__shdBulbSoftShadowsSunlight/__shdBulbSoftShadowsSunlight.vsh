precision highp float;

#define MAX_LENGTH      2000.0
#define PENUMBRA_SCALE  0.003

attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_Texcoord;

uniform vec3 u_vLightVector;

varying vec2 v_vTexcoord;

void main()
{
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION]*vec4(in_Position.xy + MAX_LENGTH*(in_Position.z*u_vLightVector.xy + PENUMBRA_SCALE*u_vLightVector.z*in_Normal.z*normalize(vec2(u_vLightVector.y, -u_vLightVector.x))), 0.0, 1.0);
    
    v_vTexcoord = in_Texcoord;
}