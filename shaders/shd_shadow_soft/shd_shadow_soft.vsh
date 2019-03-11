attribute vec3 in_Position;
attribute vec4 in_Colour;

varying vec4 v_vColour;

void main()
{
    //var _proj_matrix = [      _inv_camera_w,                   0, 0,  0,
    //                                        0,       _inv_camera_h, 0,  0,
    //                                undefined,           undefined, 0, -1,
    //                    -_transformed_cam_x, -_transformed_cam_y, 0,  1 ];
    
    //_proj_matrix[8] = _transformed_cam_x - x*_inv_camera_w;
    //_proj_matrix[9] = _transformed_cam_y - y*_inv_camera_h;
    
    mat4 matrix = gm_Matrices[MATRIX_PROJECTION];
    vec2 lightPos = vec2( matrix[2][0], matrix[2][1] );
    float lightRadius = 0.0;
    
    if ( in_Colour.r == 1.0 )
    {
        lightRadius = matrix[2][2];
    }
    else if ( in_Colour.g == 1.0 )
    {
        lightRadius = -matrix[2][2];
    }
    
    vec2 direction = normalize(in_Position.xy - lightPos);
    lightPos -= lightRadius*vec2( direction.y, -direction.x );
    
    matrix[2][0] = -matrix[3][0] - lightPos.x*matrix[0][0];
    matrix[2][1] = -matrix[3][1] - lightPos.y*matrix[1][1];
    matrix[2][2] = 0.0;
    gl_Position = matrix * vec4( in_Position.xyz, 1.0 );
    
    //v_vColour = vec4( 0.0, 0.0, 0.0, in_Colour.a );
    v_vColour = in_Colour;
    //if ( in_Colour.r == 0.0 ) v_vColour.a = 0.0;
}