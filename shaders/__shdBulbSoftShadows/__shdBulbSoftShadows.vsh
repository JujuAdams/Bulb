precision highp float;

attribute vec3 in_Position;
attribute vec2 in_TextureCoord;

varying vec2 v_vTexcoord;

void main()
{
    mat4 matrix = gm_Matrices[MATRIX_PROJECTION];
    vec3 pos = in_Position.xyz;
    
    float lightRadius = 0.0;
    if ((in_TextureCoord.x == 0.0) && (in_TextureCoord.y == 0.0))
    {
        lightRadius = matrix[2][2];
    }
    
    if (pos.z < 0.0)
    {
        lightRadius = -matrix[2][2];
        pos.z = -pos.z;
    }
    
    vec2 lightPos = vec2(matrix[2][0], matrix[2][1]);
    vec2 direction = normalize(in_Position.xy - lightPos);
    lightPos -= lightRadius*vec2(direction.y, -direction.x);
    
    matrix[2][0] = -matrix[3][0] - lightPos.x*matrix[0][0];
    matrix[2][1] = -matrix[3][1] - lightPos.y*matrix[1][1];
    matrix[2][2] = 0.0;
    gl_Position = matrix * vec4(pos, 1.0);
    
    v_vTexcoord = in_TextureCoord;
}