varying vec2 v_vTexcoord;

uniform vec2 u_vTexel;

void main()
{
    gl_FragColor = (    texture2D(gm_BaseTexture, v_vTexcoord + vec2( 2.0*u_vTexel.x,            0.0))
                 +      texture2D(gm_BaseTexture, v_vTexcoord + vec2(-2.0*u_vTexel.x,            0.0))
                 +      texture2D(gm_BaseTexture, v_vTexcoord + vec2(            0.0, 2.0*u_vTexel.y))
                 +      texture2D(gm_BaseTexture, v_vTexcoord + vec2(            0.0,-2.0*u_vTexel.y))
                 +  2.0*texture2D(gm_BaseTexture, v_vTexcoord + vec2(     u_vTexel.x,     u_vTexel.y))
                 +  2.0*texture2D(gm_BaseTexture, v_vTexcoord + vec2(    -u_vTexel.x,     u_vTexel.y))
                 +  2.0*texture2D(gm_BaseTexture, v_vTexcoord + vec2(     u_vTexel.x,    -u_vTexel.y))
                 +  2.0*texture2D(gm_BaseTexture, v_vTexcoord + vec2(    -u_vTexel.x,    -u_vTexel.y))) / 12.0;
}