varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float     u_fExposure;
uniform sampler2D u_sLightMap;

const float gamma = 2.2;

float Luminance(vec3 color)
{
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}

vec3 ChangeLuminance(vec3 color, float targetLuminance)
{
    return color * (targetLuminance / Luminance(color));
}

vec3 ReinhardExtended(vec3 color, float whitepoint)
{
    float luminance = Luminance(color);
    float numerator = luminance * (1.0 + (luminance / (whitepoint * whitepoint)));
    float luminanceNew = numerator / (1.0 + luminance);
    return ChangeLuminance(color, luminanceNew);
}

void main()
{
    gl_FragColor = v_vColour*texture2D(gm_BaseTexture, v_vTexcoord);
    gl_FragColor.rgb = pow(gl_FragColor.rgb, vec3(gamma));
    
    vec4 light = texture2D(u_sLightMap, v_vTexcoord);
    
    gl_FragColor.rgb = pow(ReinhardExtended(u_fExposure*gl_FragColor.rgb*light.rgb, 4.0), vec3(1.0/gamma));
}