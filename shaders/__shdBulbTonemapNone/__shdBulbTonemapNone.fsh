varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float     u_fExposure;
uniform sampler2D u_sLightMap;

const float gamma = 2.2;

void main()
{
    gl_FragColor = v_vColour*texture2D(gm_BaseTexture, v_vTexcoord);
    gl_FragColor.rgb = pow(gl_FragColor.rgb, vec3(gamma));
    
    vec4 light = texture2D(u_sLightMap, v_vTexcoord);
    
    gl_FragColor.rgb = pow(u_fExposure*gl_FragColor.rgb*light.rgb, vec3(1.0/gamma));
}