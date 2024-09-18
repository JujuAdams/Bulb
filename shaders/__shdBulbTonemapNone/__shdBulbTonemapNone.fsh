varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_fExposure;

const float gamma = 2.2;

void main()
{
    gl_FragColor = v_vColour*texture2D(gm_BaseTexture, v_vTexcoord);
    gl_FragColor.rgb = clamp(pow(u_fExposure*gl_FragColor.rgb, vec3(1.0/gamma)), 0.0, 1.0);
}