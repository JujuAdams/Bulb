varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define TWO_PI 6.28318530718

void main()
{
    //Unpack the rotation angle from the colour
    float angle = (v_vColour.r*65280.0 + v_vColour.b*255.0) * (TWO_PI / 65536.0);
    
    vec4 sample = texture2D(gm_BaseTexture, v_vTexcoord);
    
    vec3 vector = normalize(sample.rgb);
    vector.xy = mat2( cos(angle), sin(angle),
                     -sin(angle), cos(angle)) * vector.xy;
    
    gl_FragColor = vec4(vector, sample.a);
}
