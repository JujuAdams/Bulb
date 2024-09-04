varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_fAlphaThreshold;

void main()
{
    gl_FragColor = texture2D(gm_BaseTexture, v_vTexcoord);
    if (gl_FragColor.a < u_fAlphaThreshold) discard;
    gl_FragColor = vec4(0.5, 0.5, 1.0, 1.0);
}