function __bulb_add_occlusion_soft(_vbuff)
{
    //Set up basic transforms to turn relative coordinates in arr_shadowGeometry[] into world-space coordinates
    var _sin = dsin(image_angle);
    var _cos = dcos(image_angle);
    
    var _x_sin = image_xscale*_sin;
    var _x_cos = image_xscale*_cos;
    var _y_sin = image_yscale*_sin;
    var _y_cos = image_yscale*_cos;
    
    //Loop through every line segment, remembering that we're storing coordinate data sequentially: { Ax1, Ay1, Bx1, Bx1,   Ax2, Ay2, Bx2, Bx2, ... }
    var _vertex_array = __bulb_vertex_array;
    var _i = 0;
    repeat(__bulb_edge_count)
    {
        //Collect first coordinate pair
        var _old_ax = _vertex_array[_i++];
        var _old_ay = _vertex_array[_i++];
        var _old_bx = _vertex_array[_i++];
        var _old_by = _vertex_array[_i++];
        
        //...and transform
        var _new_ax = x + _old_ax*_x_cos + _old_ay*_y_sin;
        var _new_ay = y - _old_ax*_x_sin + _old_ay*_y_cos;
        var _new_bx = x + _old_bx*_x_cos + _old_by*_y_sin;
        var _new_by = y - _old_bx*_x_sin + _old_by*_y_cos;
        
        //Add to the vertex buffer
        vertex_position_3d(_vbuff,   _new_ax, _new_ay,  0);           vertex_texcoord(_vbuff,  1, 1);
        vertex_position_3d(_vbuff,   _new_bx, _new_by,  __BULB_ZFAR); vertex_texcoord(_vbuff,  1, 1);
        vertex_position_3d(_vbuff,   _new_bx, _new_by,  0);           vertex_texcoord(_vbuff,  1, 1);
        
        vertex_position_3d(_vbuff,   _new_ax, _new_ay,  0);           vertex_texcoord(_vbuff,  1, 1);
        vertex_position_3d(_vbuff,   _new_ax, _new_ay,  __BULB_ZFAR); vertex_texcoord(_vbuff,  1, 1);
        vertex_position_3d(_vbuff,   _new_bx, _new_by,  __BULB_ZFAR); vertex_texcoord(_vbuff,  1, 1);
        
        //Add data for the soft shadows
        vertex_position_3d(_vbuff,   _new_ax, _new_ay,  __BULB_ZFAR); vertex_texcoord(_vbuff,  1, 0);
        vertex_position_3d(_vbuff,   _new_ax, _new_ay,  0);           vertex_texcoord(_vbuff,  0, 1);
        vertex_position_3d(_vbuff,   _new_ax, _new_ay,  __BULB_ZFAR); vertex_texcoord(_vbuff,  0, 0);
        
        vertex_position_3d(_vbuff,   _new_ax, _new_ay, -__BULB_ZFAR); vertex_texcoord(_vbuff,  0, 0); //Bit of a hack. We interpret this in __shd_bulb_soft_shadows
        vertex_position_3d(_vbuff,   _new_ax, _new_ay,  0);           vertex_texcoord(_vbuff,  0, 1);
        vertex_position_3d(_vbuff,   _new_ax, _new_ay,  __BULB_ZFAR); vertex_texcoord(_vbuff,  1, 0);
    }
}