/// Initialises some variables and an array that describes the occluder
/// 
/// This code and engine are provided under the Creative Commons "Attribution - NonCommerical - ShareAlike" international license.
/// https://creativecommons.org/licenses/by-nc-sa/4.0/

function bulb_set_as_occluder()
{
    __bulb_vertex_count = 0;
    __bulb_vertex_array = [];
    __bulb_on_screen    = true;
    
    if (BULB_CACHE_DYNAMIC_OCCLUDERS)
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
        
        __bulb_light_obstacle_old_x = x;
        __bulb_light_obstacle_old_y = y;
        
        __bulb_light_vertex_cache = undefined;
        __bulb_light_vertex_cache_dirty = true;
    }
}