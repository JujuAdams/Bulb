varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_fExposure;

vec3 Unreal3(vec3 color)
{
    return color / (color + 0.155) * 1.019;
}

void main()
{
    gl_FragColor = v_vColour*texture2D(gm_BaseTexture, v_vTexcoord);
    gl_FragColor.rgb = Unreal3(u_fExposure*gl_FragColor.rgb);
}