const float PI = 3.14159265359;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vPosition;

uniform vec3 u_vLight;

float atan2( float y, float x)
{
    return (x == 0.0)? (sign(y)*PI/2.) : atan(y, x);
}

void main()
{
    vec2 delta = v_vPosition.xy - u_vLight.xy;
    float angle = atan2( delta.y, delta.x );
    float pos = 0.5 + 0.5*angle/PI;
    float dist = clamp( distance( u_vLight.xy, v_vPosition.xy )/(u_vLight.z+1.), 0., 1. );
    
    vec4 sample = texture2D( gm_BaseTexture, vec2( pos, 0. ) );
    
    if ( dist < sample.r ) discard;
    
    gl_FragColor = sample;
}