varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec4 v_vPosition;
varying vec2 v_vNormalTexcoord;

uniform vec3      u_vLightPos;
uniform sampler2D u_sNormalMap;

void main()
{
    gl_FragColor = v_vColour*texture2D(gm_BaseTexture, v_vTexcoord);
    
    gl_FragColor.a *= max(dot(normalize(u_vLightPos - v_vPosition.xyz), 2.0*texture2D(u_sNormalMap, v_vNormalTexcoord).rgb - 1.0), 0.0);
}
