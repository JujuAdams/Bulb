precision highp float;

#define MAX_LENGTH 50.0

attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_Texcoord;

uniform vec3 u_vLight;

varying vec2 v_vTexcoord;

void main()
{
    vec2 delta = in_Position.xy - u_vLight.xy;
    
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION]*vec4(in_Position.xy + MAX_LENGTH*(in_Position.z*delta + u_vLight.z*in_Normal.z*normalize(vec2(delta.y, -delta.x))), 0.0, 1.0);
    
    v_vTexcoord = in_Texcoord;
}