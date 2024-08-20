varying vec2 v_vTexcoord;

uniform vec2 u_vTexel;

void main()
{
    gl_FragColor = (4.0*texture2D(gm_BaseTexture, v_vTexcoord                                 )
                 +      texture2D(gm_BaseTexture, v_vTexcoord + vec2( u_vTexel.x,         0.0))
                 +      texture2D(gm_BaseTexture, v_vTexcoord + vec2(-u_vTexel.x,         0.0))
                 +      texture2D(gm_BaseTexture, v_vTexcoord + vec2(        0.0,  u_vTexel.y))
                 +      texture2D(gm_BaseTexture, v_vTexcoord + vec2(        0.0, -u_vTexel.y))) / 8.0;
}