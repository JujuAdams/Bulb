varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float     u_fExposure;
uniform sampler2D u_sLightMap;

const float gamma = 2.2;

vec3 Heji_BurgessDawson(vec3 color)
{
   color = max(vec3(0.0), color - 0.004);
   return (color * (6.2*color + 0.5)) / (color * (6.2*color + 1.7) + 0.06);
}

void main()
{
    gl_FragColor = v_vColour*texture2D(gm_BaseTexture, v_vTexcoord);
    gl_FragColor.rgb = pow(gl_FragColor.rgb, vec3(gamma));
    
    vec4 light = texture2D(u_sLightMap, v_vTexcoord);
    
    gl_FragColor.rgb = Heji_BurgessDawson(u_fExposure*gl_FragColor.rgb*light.rgb);
}