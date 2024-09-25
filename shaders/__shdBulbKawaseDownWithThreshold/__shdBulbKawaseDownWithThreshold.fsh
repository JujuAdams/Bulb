varying vec2 v_vTexcoord;

uniform vec2 u_vThreshold;
uniform vec2 u_vTexel;

float Luminance(vec3 color)
{
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}

void main()
{
    gl_FragColor = (4.0*texture2D(gm_BaseTexture, v_vTexcoord                                 )
                 +      texture2D(gm_BaseTexture, v_vTexcoord + vec2( u_vTexel.x,         0.0))
                 +      texture2D(gm_BaseTexture, v_vTexcoord + vec2(-u_vTexel.x,         0.0))
                 +      texture2D(gm_BaseTexture, v_vTexcoord + vec2(        0.0,  u_vTexel.y))
                 +      texture2D(gm_BaseTexture, v_vTexcoord + vec2(        0.0, -u_vTexel.y))) / 8.0;
    
    gl_FragColor.rgb *= smoothstep(u_vThreshold.x, u_vThreshold.y, Luminance(gl_FragColor.rgb));
}