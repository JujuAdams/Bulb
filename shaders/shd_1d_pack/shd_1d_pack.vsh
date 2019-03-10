const float PI = 3.14159265359;

attribute vec3 in_Position;
attribute vec4 in_Colour;

varying vec4 v_vColour;

uniform vec3 u_vLight;

float atan2( float y, float x)
{
    return (x == 0.0)? (sign(y)*PI/2.) : atan(y, x);
}

void main()
{
    vec2 delta = in_Position.xy - u_vLight.xy;
    float angle = atan2( delta.y, delta.x );
    float pos = angle/PI;
    float dist = clamp( distance( u_vLight.xy, in_Position.xy )/(u_vLight.z+1.), 0., 1. );
    
    gl_Position = vec4( pos, 1.-1./720., dist, 1. );
    
    v_vColour = vec4( dist, dist, dist, 1. );
}