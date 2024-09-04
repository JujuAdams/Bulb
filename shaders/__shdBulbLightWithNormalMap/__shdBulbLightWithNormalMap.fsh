varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec2 v_vPosition;

uniform sampler2D u_sNormalMap;
uniform vec4      u_vInfo;
uniform vec4      u_vCamera;

void main()
{
    #ifdef _YY_HLSL11_
        vec2 objectPos = v_vPosition*vec2(1.0, -1.0);
    #else
        vec2 objectPos = v_vPosition;
    #endif
    
    vec3 lightPos = vec3((u_vInfo.xy - u_vCamera.xy) / u_vCamera.zw, u_vInfo.z);
    
    vec4 normalSample = texture2D(u_sNormalMap, 0.5 + 0.5*objectPos);
    
    gl_FragColor = v_vColour*texture2D(gm_BaseTexture, v_vTexcoord);
    gl_FragColor.rgb *= u_vInfo.w*max(0.0, dot(normalize(lightPos - vec3(objectPos, 0.0)), 2.0*normalSample.xyz - 1.0));
}