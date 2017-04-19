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
// Takes 2 textures and runs through the normal fixing for spine sprites
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D partSkin;
uniform sampler2D normalSkin;
uniform float xscale[15];
uniform float yscale[15];
uniform float xrot[15];
uniform float yrot[15];

void main()
{
    int part = int( floor(255.0 * texture2D( partSkin, v_vTexcoord ).r + 0.5) );
    vec2 signScale = vec2( xscale[part] , yscale[part] );
    vec2 rotation = vec2( xrot[part] , yrot[part] );
    vec4 normColor = texture2D( normalSkin, v_vTexcoord );
    vec3 normal = normColor.rgb;
    vec2 tempNorm = vec2(0.0, 0.0);
    //change scale to -1.0 to 1.0
    normal.rgb = normalize(normal.rgb * 2.0 - 1.0);
    //flip normals for negative scale
    normal.x = normal.x * signScale.x;
    normal.y = normal.y * signScale.y;
    //rotate normals for rotated sprites
    tempNorm.x = normal.x * rotation.x - normal.y * rotation.y;
    tempNorm.y = normal.x * rotation.y + normal.y * rotation.x;
    normal.x = tempNorm.x;
    normal.y = tempNorm.y;
    //change scale to 0.0 to 1.0
    normal.rgb = (normal.rgb + 1.0) / 2.0;
    
    gl_FragColor = v_vColour * vec4(normal.rgb,normColor.a);
}

