//  Initialises some variables and an array that describes the occluder.
//
//  return: Nothing
//  
//  May 2017
//  @jujuadams
//  /u/jujuadam
//  Juju on the GMC
//
//  Based on the YAILSE system by xot (John Leffingwell) of gmlscripts.com
//  
//  This code and engine are provided under the Creative Commons "Attribution - NonCommerical - ShareAlike" international license.
//  https://creativecommons.org/licenses/by-nc-sa/4.0/

shadow_geometry_size   = 0;
shadow_geometry_count  = 0;
arr_shadow_geometry[0] = 0;
light_on_screen        = true;

if (LIGHTING_DYNAMIC_CACHING_ENABLED) {
    last_image_angle = image_angle;
    last_image_x_scale = image_xscale;
    last_image_y_scale = image_yscale;

    var _sin = dsin( image_angle );
    var _cos = dcos( image_angle );

    last_x_sin = image_xscale*_sin;
    last_x_cos = image_xscale*_cos;
    last_y_sin = image_yscale*_sin;
    last_y_cos = image_yscale*_cos;

    light_obstacle_old_x = x;
    light_obstacle_old_y = y;

    light_obstacle_vertex_cache = undefined;

    light_first_time_vertex_cache_perform_flag = true;
}