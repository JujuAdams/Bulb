varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_fExposure;

float Luminance(vec3 color)
{
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}

vec3 ChangeLuminance(vec3 color, float targetLuminance)
{
    return color * (targetLuminance / Luminance(color));
}

vec3 Reinhard(vec3 color)
{
    float luminance = Luminance(color);
    float luminanceNew = luminance / (1.0 + luminance);
    return ChangeLuminance(color, luminanceNew);
}

void main()
{
    gl_FragColor = v_vColour*texture2D(gm_BaseTexture, v_vTexcoord);
    gl_FragColor.rgb = Reinhard(u_fExposure*gl_FragColor.rgb);
    gl_FragColor.rgb = pow(gl_FragColor.rgb, vec3(1.0/2.2));
}