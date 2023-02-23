precision highp float;

attribute vec3 in_Position;
attribute vec3 in_Normal;

varying vec2 v_vTexcoord;

void main()
{
    mat4 matrix = gm_Matrices[MATRIX_PROJECTION];
    
    //Push out penumbra fringes
    vec2 direction = vec2(matrix[2][0], matrix[2][1]);
    matrix[2][0] += in_Normal.z*matrix[2][2]*direction.y;
    matrix[2][1] -= in_Normal.z*matrix[2][2]*direction.x;
    
    matrix[2][1] *= matrix[2][3]; //Aspect ratio correction
    
    matrix[2][2] = 0.0;
    matrix[2][3] = 0.0;
    gl_Position = matrix * vec4(in_Position.xyz, 1.0);
    
    v_vTexcoord = in_Normal.xy;
}