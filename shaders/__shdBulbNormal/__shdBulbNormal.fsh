varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_fAlphaThreshold;
uniform float u_fDisable;

const float twoPi = 2.0*3.14159265;
const float conversion = twoPi / (257.0 + (1.0 / 63.0));

void main()
{
    gl_FragColor = texture2D(gm_BaseTexture, v_vTexcoord);
    if (gl_FragColor.a < u_fAlphaThreshold) discard;
    gl_FragColor.a = 1.0;
    
    gl_FragColor.rgb = 2.0*gl_FragColor.rgb - 1.0;
    
    //Use the least significant bits in the red channel for the
    float xFlip = mod(v_vColour.r*255.0, 2.0);
    float yFlip = mod((v_vColour.r*255.0 - xFlip) / 2.0, 2.0);
    
    //Technically we should remove the least significant bits (the x flip and y flip bits)
    //Ultimately, it doesn't change the outcome much
    float angle  = dot(v_vColour.rgb, conversion*vec3(1.0/63.0, 1.0, 256.0));
    float sine   = sin(angle);
	float cosine = cos(angle);
    mat2  matrix = mat2(cosine, -sine, sine, cosine)*(mat2(1.0 - 2.0*xFlip, 0.0, 0.0, 1.0 - 2.0*yFlip));
    
    gl_FragColor.rg = 0.5 + 0.5*(matrix*gl_FragColor.rg);
}