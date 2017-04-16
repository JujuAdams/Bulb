///lighting_add_occlusion( vertex buffer )
//
//  Adds an object's pre-defined shadow casting geometry to a vertex buffer, after having been appropriately transformed.
//  Should be called with() the shadow casting object.
//
//  return: Nothing
//  
//  April 2017
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
d3d_transform_set_scaling( image_xscale, image_yscale, 0 );
d3d_transform_add_rotation_z( image_angle );
d3d_transform_add_translation( round( x ), round( y ), 0 );

//Loop through every line segment, remembering that we're storing coordinate data sequentially: { Ax1, Ay1, Bx1, Bx1,   Ax2, Ay2, Bx2, Bx2, ... }
for( var _i = 0; _i < shadow_geometry_size; _i += 4 ) {
    
    //Collect first coordinate pair and transform
    var _array = d3d_transform_vertex( arr_shadow_geometry[_i  ], arr_shadow_geometry[_i+1], 0 );
    var _ax = _array[0];
    var _ay = _array[1];
    
    //Collect second coordinate pair and transform
    var _array = d3d_transform_vertex( arr_shadow_geometry[_i+2], arr_shadow_geometry[_i+3], 0 );
    var _bx = _array[0];
    var _by = _array[1];
    
    //Deliberately create vertices the wrong way round (anticlockwise) to take advantage of culling, allowing light into but not out of a shape ("self-lighting")
    //This feature is off by default as it requires some conscientious design to avoid glitches
    vertex_position_3d( _vbuff,   _ax, _ay, 0 );
    vertex_position_3d( _vbuff,   _bx, _by, LIGHTING_Z_LIMIT );
    vertex_position_3d( _vbuff,   _bx, _by, 0 );
    
    vertex_position_3d( _vbuff,   _ax, _ay, 0 );
    vertex_position_3d( _vbuff,   _ax, _ay, LIGHTING_Z_LIMIT );
    vertex_position_3d( _vbuff,   _bx, _by, LIGHTING_Z_LIMIT );
    
}

d3d_transform_set_identity();
