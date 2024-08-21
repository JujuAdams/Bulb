varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    gl_FragColor = texture2D(gm_BaseTexture, v_vTexcoord);
    gl_FragColor.rgb = clamp(0.5 + 0.5*gl_FragColor.rgb, 0.0, 1.0);
    gl_FragColor.a = 1.0;
}
