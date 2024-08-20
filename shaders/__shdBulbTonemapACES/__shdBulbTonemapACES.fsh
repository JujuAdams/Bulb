varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_fExposure;

vec3 ACES(vec3 color)
{
    // Narkowicz 2015, "ACES Filmic Tone Mapping Curve"
    const float a = 2.51;
    const float b = 0.03;
    const float c = 2.43;
    const float d = 0.59;
    const float e = 0.14;
    return (color * (a * color + b)) / (color * (c * color + d) + e);
}

void main()
{
    gl_FragColor = v_vColour*texture2D(gm_BaseTexture, v_vTexcoord);
    gl_FragColor.rgb = ACES(u_fExposure*gl_FragColor.rgb);
    gl_FragColor.rgb = pow(gl_FragColor.rgb, vec3(1.0/2.2));
}