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
// Rotate and flip normal map
// Inputs: rotation- cos(angle),sin(angle) signScale- sign(xscale),sign(yscale),(no zero)
// Default tex: normal map
// Output: Fixed normal map
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 rotation;    //x=cos(angle),y=sin(angle)
uniform vec2 signScale;   //x=sign(xscale),y=sign(yscale)

void main()
{
    vec4 normColor = texture2D( gm_BaseTexture, v_vTexcoord );
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

