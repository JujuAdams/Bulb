varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define TWO_PI 6.28318530718

void main()
{
    //Unpack the rotation angle from the colour
    float angle = (v_vColour.r*65280.0 + v_vColour.g*255.0) * (TWO_PI / 65536.0);
    
    //Unpack our scaling parity bits
    float encodedScaling = 255.0*v_vColour.b;
    vec3 scale = vec3(2.0*mod(encodedScaling, 2.0) - 1.0,
                      2.0*floor(encodedScaling/2.0) - 1.0,
                      1.0); 
    
    vec4 sample = texture2D(gm_BaseTexture, v_vTexcoord);
    
    vec3 vector = scale*normalize(2.0*sample.rgb - 1.0);
    vector.xy = mat2(cos(angle), -sin(angle),
                     sin(angle),  cos(angle)) * vector.xy;
    
    gl_FragColor = vec4(0.5 + 0.5*vector, v_vColour.a*sample.a);
}
