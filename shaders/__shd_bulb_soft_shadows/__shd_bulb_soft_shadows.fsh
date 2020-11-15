precision highp float;

varying vec2 v_vTexcoord;

void main()
{
    gl_FragColor = vec4(0.0, 0.0, 0.0, smoothstep(0.0, 1.0, v_vTexcoord.x / (1.0 - v_vTexcoord.y))); //Emulation of a penumbra texture
}