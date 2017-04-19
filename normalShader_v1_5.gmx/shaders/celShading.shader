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
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

const float numColors = 4.0;

void main()
{   
    vec3 myColor = texture2D( gm_BaseTexture, v_vTexcoord ).rgb;
    float L = 0.5 * ( min( myColor.r, min( myColor.g, myColor.b)) + max( myColor.r, max( myColor.g, myColor.b)) );
    float newL = floor( L * numColors + 0.5 ) / numColors;
    float deltaL = newL - L;
    vec3 myNewColor;
    if(deltaL > 0.0){
        myNewColor.rgb = (1.0 - myColor.rgb) * deltaL + myColor.rgb;
    } else {
        myNewColor.rgb = myColor.rgb * deltaL + myColor.rgb;
    }
    gl_FragColor = v_vColour * vec4(myNewColor.rgb,1.0);
}

