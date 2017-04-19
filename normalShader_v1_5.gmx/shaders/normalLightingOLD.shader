//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~//
// Normal Lighting system
// Run this shader for each light using additive blending to surface
// (that surface should be cleared first with ambience color/image)
// Then using multiply blending, draw that surface to screen.
// Input tex: Normal map.
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 res;
uniform vec3 lightPos;
uniform vec4 lightColor;
uniform float lightRad;
uniform bool type;

float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float noise(float strength)
{
    float n = rand(v_vTexcoord);
    n = (n * strength + 1.0 - strength);
    return n;
}

void main()
{
    vec4 normal = texture2D( gm_BaseTexture, v_vTexcoord );
    vec3 lightDir;
    float D;
    float normD;
    if(type){
        lightDir.x = (lightPos.x - v_vTexcoord.x ) * res.x;
        lightDir.y = (lightPos.y - v_vTexcoord.y ) * -res.y;
        lightDir.z = lightPos.z;
        D = length(lightDir);
        normD = D / lightRad;
    } else {
        lightDir = lightPos;
        D = 1.0;
        normD = 0.0;
    }
    vec3 N = normalize(normal.rgb * 2.0 - 1.0);
    vec3 L = lightDir.xyz/D;
    vec3 Diffuse = (lightColor.rgb * lightColor.a) * max(dot(N, L), 0.0);// * noise(0.8);
    //old attenuation that is wrong
    float attenuation = 1.0 - min(1.0, normD * normD );
    //float attenuation = max((1.0 - normD), 0.0) * max((1.0 - normD), 0.0);
    vec3 finalLight = Diffuse * attenuation;
    gl_FragColor = v_vColour * vec4(finalLight.rgb, normal.a);
}

