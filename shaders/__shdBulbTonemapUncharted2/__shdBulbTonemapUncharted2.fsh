varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_fExposure;

const float gamma = 2.2;

vec3 Uncharted2(vec3 color)
{
    float A = 0.15;
    float B = 0.50;
    float C = 0.10;
    float D = 0.20;
    float E = 0.02;
    float F = 0.30;
    
    return ((color*(A*color+C*B)+D*E)/(color*(A*color+B)+D*F))-E/F;
}

void main()
{
    gl_FragColor = v_vColour*texture2D(gm_BaseTexture, v_vTexcoord);
    
    gl_FragColor.rgb = Uncharted2(u_fExposure*2.0*gl_FragColor.rgb);
    
    gl_FragColor.rgb = pow(gl_FragColor.rgb, vec3(1.0/gamma));
}