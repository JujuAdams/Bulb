varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec3 sample = texture2D(gm_BaseTexture, v_vTexcoord).rgb;
    gl_FragColor = vec4(v_vColour.rgb, v_vColour.a*max(sample.r, max(sample.g, sample.b)));
}