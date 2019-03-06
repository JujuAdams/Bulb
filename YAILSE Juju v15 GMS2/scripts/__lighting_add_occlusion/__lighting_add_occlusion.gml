/// @param vertex_buffer
//
//  Adds an object's occluder geometry to a vertex buffer, after having been appropriately transformed.
//  Should be called with() the shadow casting object.
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

var _vbuff = argument0;

if ( !LIGHTING_CACHE_DYNAMIC_OCCLUDERS ) {

	//Set up basic transforms to turn relative coordinates in arr_shadowGeometry[] into world-space coordinates
	var _sin = dsin( image_angle );
	var _cos = dcos( image_angle );

	var _x_sin = image_xscale*_sin;
	var _x_cos = image_xscale*_cos;
	var _y_sin = image_yscale*_sin;
	var _y_cos = image_yscale*_cos;

	//Loop through every line segment, remembering that we're storing coordinate data sequentially: { Ax1, Ay1, Bx1, Bx1,   Ax2, Ay2, Bx2, Bx2, ... }
	var _i = 0;
	repeat( shadow_geometry_count ) {
		
		//Collect first coordinate pair
		var _old_ax = arr_shadow_geometry[_i++];
		var _old_ay = arr_shadow_geometry[_i++];
		var _old_bx = arr_shadow_geometry[_i++];
		var _old_by = arr_shadow_geometry[_i++];
		
		//...and transform
		var _new_ax = x + _old_ax*_x_cos + _old_ay*_y_sin;
		var _new_ay = y - _old_ax*_x_sin + _old_ay*_y_cos;
		var _new_bx = x + _old_bx*_x_cos + _old_by*_y_sin;
		var _new_by = y - _old_bx*_x_sin + _old_by*_y_cos;
		
		//Using textures (rather than untextureed) saves on shader_set() overhead... likely a trade-off depending on the GPU
		vertex_position_3d( _vbuff,   _new_ax, _new_ay, 0 );             vertex_colour( _vbuff,   c_black, 1 ); vertex_texcoord( _vbuff, global.lighting_black_u, global.lighting_black_v );
		vertex_position_3d( _vbuff,   _new_bx, _new_by, LIGHTING_ZFAR ); vertex_colour( _vbuff,   c_black, 1 ); vertex_texcoord( _vbuff, global.lighting_black_u, global.lighting_black_v );
		vertex_position_3d( _vbuff,   _new_bx, _new_by, 0 );             vertex_colour( _vbuff,   c_black, 1 ); vertex_texcoord( _vbuff, global.lighting_black_u, global.lighting_black_v );
		
		vertex_position_3d( _vbuff,   _new_ax, _new_ay, 0 );             vertex_colour( _vbuff,   c_black, 1 ); vertex_texcoord( _vbuff, global.lighting_black_u, global.lighting_black_v );
		vertex_position_3d( _vbuff,   _new_ax, _new_ay, LIGHTING_ZFAR ); vertex_colour( _vbuff,   c_black, 1 ); vertex_texcoord( _vbuff, global.lighting_black_u, global.lighting_black_v );
		vertex_position_3d( _vbuff,   _new_bx, _new_by, LIGHTING_ZFAR ); vertex_colour( _vbuff,   c_black, 1 ); vertex_texcoord( _vbuff, global.lighting_black_u, global.lighting_black_v );
		
	}
    
} else {
    
	var _light_occlusion_cache_needed = false;

	if ( light_vertex_cache_dirty ) {
		light_vertex_cache_dirty = false;
		_light_occlusion_cache_needed = true;
	}

	if ( (last_image_angle != image_angle) or (last_image_x_scale != image_xscale) or (last_image_y_scale!= image_yscale) ) {
        
		last_image_angle   = image_angle;
		last_image_x_scale = image_xscale;
		last_image_y_scale = image_yscale;

		var _sin = dsin( image_angle );
		var _cos = dcos( image_angle );

		last_x_sin = image_xscale*_sin;
		last_x_cos = image_xscale*_cos;
		last_y_sin = image_yscale*_sin;
		last_y_cos = image_yscale*_cos;
		
		_light_occlusion_cache_needed = true;
	}

	var _x_sin = last_x_sin;
	var _x_cos = last_x_cos;
	var _y_sin = last_y_sin;
	var _y_cos = last_y_cos;

	if ( (light_obstacle_old_x != x) or (light_obstacle_old_y != y) ) {
		light_obstacle_old_x = x;
		light_obstacle_old_y = y;
		_light_occlusion_cache_needed = true;
	}
    
	//Loop through every line segment, remembering that we're storing coordinate data sequentially: { Ax1, Ay1, Bx1, Bx1,   Ax2, Ay2, Bx2, Bx2, ... }
	var _i = 0;
	if ( _light_occlusion_cache_needed ) {
        
		repeat( shadow_geometry_count ) {
		
			//Collect first coordinate pair
			var _old_ax = arr_shadow_geometry[_i++];
			var _old_ay = arr_shadow_geometry[_i++];
			var _old_bx = arr_shadow_geometry[_i++];
			var _old_by = arr_shadow_geometry[_i++];
		    
			//...and transform
			var _new_ax = x + _old_ax*_x_cos + _old_ay*_y_sin;
			var _new_ay = y - _old_ax*_x_sin + _old_ay*_y_cos;
			var _new_bx = x + _old_bx*_x_cos + _old_by*_y_sin;
			var _new_by = y - _old_bx*_x_sin + _old_by*_y_cos;
		    
            //Store these values in the cache
			light_vertex_cache[_i-4] = _new_ax;
			light_vertex_cache[_i-3] = _new_ay;
			light_vertex_cache[_i-2] = _new_bx;
			light_vertex_cache[_i-1] = _new_by;
		    
			//Using textures (rather than untextureed) saves on shader_set() overhead... likely a trade-off depending on the GPU
			vertex_position_3d( _vbuff,   _new_ax, _new_ay, 0 );             vertex_colour( _vbuff,   c_black, 1 ); vertex_texcoord( _vbuff, global.lighting_black_u, global.lighting_black_v );
			vertex_position_3d( _vbuff,   _new_bx, _new_by, LIGHTING_ZFAR ); vertex_colour( _vbuff,   c_black, 1 ); vertex_texcoord( _vbuff, global.lighting_black_u, global.lighting_black_v );
			vertex_position_3d( _vbuff,   _new_bx, _new_by, 0 );             vertex_colour( _vbuff,   c_black, 1 ); vertex_texcoord( _vbuff, global.lighting_black_u, global.lighting_black_v );
		    
			vertex_position_3d( _vbuff,   _new_ax, _new_ay, 0 );             vertex_colour( _vbuff,   c_black, 1 ); vertex_texcoord( _vbuff, global.lighting_black_u, global.lighting_black_v );
			vertex_position_3d( _vbuff,   _new_ax, _new_ay, LIGHTING_ZFAR ); vertex_colour( _vbuff,   c_black, 1 ); vertex_texcoord( _vbuff, global.lighting_black_u, global.lighting_black_v );
			vertex_position_3d( _vbuff,   _new_bx, _new_by, LIGHTING_ZFAR ); vertex_colour( _vbuff,   c_black, 1 ); vertex_texcoord( _vbuff, global.lighting_black_u, global.lighting_black_v );
		    
		}
        
	} else {
        
		repeat( shadow_geometry_count ) {
			
			//Build from cache
			var _new_ax = light_vertex_cache[_i++];
			var _new_ay = light_vertex_cache[_i++];
			var _new_bx = light_vertex_cache[_i++];
			var _new_by = light_vertex_cache[_i++];
			
			//Using textures (rather than untextureed) saves on shader_set() overhead... likely a trade-off depending on the GPU
			vertex_position_3d( _vbuff,   _new_ax, _new_ay, 0 );             vertex_colour( _vbuff,   c_black, 1 ); vertex_texcoord( _vbuff, global.lighting_black_u, global.lighting_black_v );
			vertex_position_3d( _vbuff,   _new_bx, _new_by, LIGHTING_ZFAR ); vertex_colour( _vbuff,   c_black, 1 ); vertex_texcoord( _vbuff, global.lighting_black_u, global.lighting_black_v );
			vertex_position_3d( _vbuff,   _new_bx, _new_by, 0 );             vertex_colour( _vbuff,   c_black, 1 ); vertex_texcoord( _vbuff, global.lighting_black_u, global.lighting_black_v );
		    
			vertex_position_3d( _vbuff,   _new_ax, _new_ay, 0 );             vertex_colour( _vbuff,   c_black, 1 ); vertex_texcoord( _vbuff, global.lighting_black_u, global.lighting_black_v );
			vertex_position_3d( _vbuff,   _new_ax, _new_ay, LIGHTING_ZFAR ); vertex_colour( _vbuff,   c_black, 1 ); vertex_texcoord( _vbuff, global.lighting_black_u, global.lighting_black_v );
			vertex_position_3d( _vbuff,   _new_bx, _new_by, LIGHTING_ZFAR ); vertex_colour( _vbuff,   c_black, 1 ); vertex_texcoord( _vbuff, global.lighting_black_u, global.lighting_black_v );
                
		}
	}
}