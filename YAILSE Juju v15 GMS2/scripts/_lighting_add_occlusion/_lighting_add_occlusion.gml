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

//Set up basic transforms to turn relative coordinates in arr_shadowGeometry[] into world-space coordinates
var _sin = dsin( image_angle );
var _cos = dcos( image_angle );

var _x_sin = image_xscale*_sin;
var _x_cos = image_xscale*_cos;
var _y_sin = image_yscale*_sin;
var _y_cos = image_yscale*_cos;

//Loop through every line segment, remembering that we're storing coordinate data sequentially: { Ax1, Ay1, Bx1, Bx1,   Ax2, Ay2, Bx2, Bx2, ... }
for( var _i = 0; _i < shadow_geometry_size; _i += 4 ) {
    
	//Collect first coordinate pair
	var _old_ax = arr_shadow_geometry[_i  ];
	var _old_ay = arr_shadow_geometry[_i+1];
	var _old_bx = arr_shadow_geometry[_i+2];
	var _old_by = arr_shadow_geometry[_i+3];
	
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