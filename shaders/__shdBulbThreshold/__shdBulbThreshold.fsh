varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_vThreshold;

float Luminance(vec3 color)
{
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}

void main()
{
    gl_FragColor = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
    gl_FragColor.rgb *= smoothstep(u_vThreshold.x, u_vThreshold.y, Luminance(gl_FragColor.rgb));
}