varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 sample = texture2D(gm_BaseTexture, v_vTexcoord);
    gl_FragColor = v_vColour*vec4(sample.rgb, 1.0);
    gl_FragColor.rgb *= gl_FragColor.a;
}
