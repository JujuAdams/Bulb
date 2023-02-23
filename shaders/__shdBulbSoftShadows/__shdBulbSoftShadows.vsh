precision highp float;

attribute vec3 in_Position;
attribute vec3 in_Normal;

varying vec2 v_vTexcoord;

void main()
{
    mat4 matrix = gm_Matrices[MATRIX_PROJECTION];
    
    vec2 lightPos = vec2(matrix[2][0], matrix[2][1]);
    vec2 direction = normalize(in_Position.xy - lightPos);
    lightPos -= in_Normal.z*matrix[2][2]*vec2(direction.y, -direction.x);
    
    matrix[2][0] = -matrix[3][0] - lightPos.x*matrix[0][0];
    matrix[2][1] = -matrix[3][1] - lightPos.y*matrix[1][1];
    matrix[2][2] = 0.0;
    gl_Position = matrix * vec4(in_Position.xyz, 1.0);
    
    v_vTexcoord = in_Normal.xy;
}