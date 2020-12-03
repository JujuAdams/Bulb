function __bulb_add_occlusion_hard(_vbuff)
{
    if (!BULB_CACHE_DYNAMIC_OCCLUDERS)
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
        repeat(__bulb_vertex_count)
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
            vertex_position_3d(_vbuff,   _new_ax, _new_ay,  0);         vertex_colour(_vbuff,   c_black, 1);
            vertex_position_3d(_vbuff,   _new_bx, _new_by,  BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
            vertex_position_3d(_vbuff,   _new_bx, _new_by,  0);         vertex_colour(_vbuff,   c_black, 1);
            
            vertex_position_3d(_vbuff,   _new_ax, _new_ay,  0);         vertex_colour(_vbuff,   c_black, 1);
            vertex_position_3d(_vbuff,   _new_ax, _new_ay,  BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
            vertex_position_3d(_vbuff,   _new_bx, _new_by,  BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
        }
    }
    else
    {
        if ((__bulb_last_image_angle != image_angle) || (__bulb_last_image_x_scale != image_xscale) || (__bulb_last_image_y_scale != image_yscale))
        {
            __bulb_last_image_angle   = image_angle;
            __bulb_last_image_x_scale = image_xscale;
            __bulb_last_image_y_scale = image_yscale;
            
            var _sin = dsin(image_angle);
            var _cos = dcos(image_angle);
            
            __bulb_last_x_sin = image_xscale*_sin;
            __bulb_last_x_cos = image_xscale*_cos;
            __bulb_last_y_sin = image_yscale*_sin;
            __bulb_last_y_cos = image_yscale*_cos;
            
            __bulb_light_vertex_cache_dirty = true;
        }
        
        var _x_sin = __bulb_last_x_sin;
        var _x_cos = __bulb_last_x_cos;
        var _y_sin = __bulb_last_y_sin;
        var _y_cos = __bulb_last_y_cos;
        
        if ((__bulb_light_obstacle_old_x != x) || (__bulb_light_obstacle_old_y != y))
        {
            __bulb_light_obstacle_old_x = x;
            __bulb_light_obstacle_old_y = y;
            __bulb_light_vertex_cache_dirty = true;
        
        }
        
        //Loop through every line segment, remembering that we're storing coordinate data sequentially: { Ax1, Ay1, Bx1, Bx1,   Ax2, Ay2, Bx2, Bx2, ... }
        if (__bulb_light_vertex_cache_dirty)
        {
            __bulb_light_vertex_cache_dirty = false;
            
            var _vertex_array = __bulb_vertex_array;
            var _vertex_cache = __bulb_light_vertex_cache;
            var _i = 0;
            repeat(__bulb_vertex_count)
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
                
                //Store these values in the cache
                _vertex_cache[@ _i-4] = _new_ax;
                _vertex_cache[@ _i-3] = _new_ay;
                _vertex_cache[@ _i-2] = _new_bx;
                _vertex_cache[@ _i-1] = _new_by;
                
                //Using textures (rather than untextureed) saves on shader_set() overhead... likely a trade-off depending on the GPU
                vertex_position_3d(_vbuff,   _new_ax, _new_ay, 0);         vertex_colour(_vbuff,   c_black, 1);
                vertex_position_3d(_vbuff,   _new_bx, _new_by, BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
                vertex_position_3d(_vbuff,   _new_bx, _new_by, 0);         vertex_colour(_vbuff,   c_black, 1);
                
                vertex_position_3d(_vbuff,   _new_ax, _new_ay, 0);         vertex_colour(_vbuff,   c_black, 1);
                vertex_position_3d(_vbuff,   _new_ax, _new_ay, BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
                vertex_position_3d(_vbuff,   _new_bx, _new_by, BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
            }
        }
        else
        {
            var _vertex_array = __bulb_light_vertex_cache;
            var _i = 0;
            repeat(__bulb_vertex_count)
            {
                //Build from cache
                var _new_ax = _vertex_array[_i++];
                var _new_ay = _vertex_array[_i++];
                var _new_bx = _vertex_array[_i++];
                var _new_by = _vertex_array[_i++];
                
                //Using textures (rather than untextureed) saves on shader_set() overhead... likely a trade-off depending on the GPU
                vertex_position_3d(_vbuff,   _new_ax, _new_ay, 0);         vertex_colour(_vbuff,   c_black, 1);
                vertex_position_3d(_vbuff,   _new_bx, _new_by, BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
                vertex_position_3d(_vbuff,   _new_bx, _new_by, 0);         vertex_colour(_vbuff,   c_black, 1);
                
                vertex_position_3d(_vbuff,   _new_ax, _new_ay, 0);         vertex_colour(_vbuff,   c_black, 1);
                vertex_position_3d(_vbuff,   _new_ax, _new_ay, BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
                vertex_position_3d(_vbuff,   _new_bx, _new_by, BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1); 
            }
        }
    }
}