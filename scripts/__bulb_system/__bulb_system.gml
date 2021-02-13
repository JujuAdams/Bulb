#macro __BULB_VERSION        "20.0.0"
#macro __BULB_DATE           "2021-02-12"
#macro __BULB_ON_DIRECTX     ((os_type == os_windows) || (os_type == os_xboxone) || (os_type == os_uwp) || (os_type == os_winphone) || (os_type == os_win8native))
#macro __BULB_ZFAR           16000
#macro __BULB_FLIP_CAMERA_Y  __BULB_ON_DIRECTX
#macro __BULB_PARTIAL_CLEAR  true
#macro __BULB_SQRT_2         1.41421356237

__bulb_trace("Welcome to Bulb by @jujuadams! This is version " + __BULB_VERSION + ", " + __BULB_DATE);

//Create a couple vertex formats
vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_colour();
global.__bulb_format_3d_colour = vertex_format_end();

//Create a standard vertex format
vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_texcoord();
global.__bulb_format_3d_texture = vertex_format_end();

function __bulb_trace()
{
    var _string = "";
    
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    show_debug_message("Bulb: " + _string);
}



function __bulb_add_occlusion_hard(_vbuff)
{
    //Set up basic transforms to turn relative coordinates in arr_shadowGeometry[] into world-space coordinates
    var _sin = dsin(angle);
    var _cos = dcos(angle);
    
    var _x_sin = xscale*_sin;
    var _x_cos = xscale*_cos;
    var _y_sin = yscale*_sin;
    var _y_cos = yscale*_cos;
    
    //Loop through every line segment, remembering that we're storing coordinate data sequentially: { Ax1, Ay1, Bx1, Bx1,   Ax2, Ay2, Bx2, Bx2, ... }
    var _vertex_array = vertex_array;
    var _i = 0;
    repeat(array_length(_vertex_array) div 4)
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
        vertex_position_3d(_vbuff,   _new_ax, _new_ay,  0);           vertex_colour(_vbuff,   c_black, 1);
        vertex_position_3d(_vbuff,   _new_bx, _new_by,  __BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
        vertex_position_3d(_vbuff,   _new_bx, _new_by,  0);           vertex_colour(_vbuff,   c_black, 1);
        
        vertex_position_3d(_vbuff,   _new_ax, _new_ay,  0);           vertex_colour(_vbuff,   c_black, 1);
        vertex_position_3d(_vbuff,   _new_ax, _new_ay,  __BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
        vertex_position_3d(_vbuff,   _new_bx, _new_by,  __BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
    }
}



function __bulb_add_occlusion_soft(_vbuff)
{
    //Set up basic transforms to turn relative coordinates in arr_shadowGeometry[] into world-space coordinates
    var _sin = dsin(angle);
    var _cos = dcos(angle);
    
    var _x_sin = xscale*_sin;
    var _x_cos = xscale*_cos;
    var _y_sin = yscale*_sin;
    var _y_cos = yscale*_cos;
    
    //Loop through every line segment, remembering that we're storing coordinate data sequentially: { Ax1, Ay1, Bx1, Bx1,   Ax2, Ay2, Bx2, Bx2, ... }
    var _vertex_array = vertex_array;
    var _i = 0;
    repeat(array_length(_vertex_array) div 4)
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



function __bulb_rect_in_rect(_ax1, _ay1, _ax2, _ay2, _bx1, _by1, _bx2, _by2)
{
    return !((_bx1 > _ax2) || (_bx2 < _ax1) || (_by1 > _ay2) || (_by2 < _ay1));
}