///scr_lighting_add_occlusion( vertex buffer )
//
//  Adds an object's pre-defined shadow casting geometry to a vertex buffer, after having been appropriately transformed.
//  Should be called with() the shadow casting object.
//
//  return: Nothing
//  
//  November 2015
//  @jujuadams
//  /u/jujuadam
//  Juju on the GMC
//
//  Based on the YAILSE system by xot (John Leffingwell) of gmlscripts.com
//  
//  This code and engine are provided under the Creative Commons "Attribution - NonCommerical - ShareAlike" international license.
//  https://creativecommons.org/licenses/by-nc-sa/4.0/

var vbuff = argument0;
var array, vAx, vAy, vBx, vBy;

//Set up basic transforms to turn relative coordinates in arr_shadowGeometry[] into world-space coordinates
d3d_transform_set_scaling( image_xscale, image_yscale, 0 );
d3d_transform_add_rotation_z( image_angle );
d3d_transform_add_translation( round( x ), round( y ), 0 );

//Loop through every line segment, remembering that we're storing coordinate data sequentially: { Ax1, Ay1, Bx1, Bx1,   Ax2, Ay2, Bx2, Bx2, ... }
for( var i = 0; i < shadowGeometry_size; i += 4 ) {
    
    //Collect first coordinate pair and transform
    array = d3d_transform_vertex( arr_shadowGeometry[i  ], arr_shadowGeometry[i+1], 0 );
    vAx = array[0];
    vAy = array[1];
    
    //Collect second coordinate pair and transform
    array = d3d_transform_vertex( arr_shadowGeometry[i+2], arr_shadowGeometry[i+3], 0 );
    vBx = array[0];
    vBy = array[1];
    
    //Deliberately create vertices the wrong way round (anticlockwise) to take advantage of culling, allowing light into but not out of a shape ("self-lighting")
    //This feature is off by default as it requires some conscientious design to avoid glitches
    vertex_position_3d( vbuff,   vAx, vAy, 0 );
    vertex_position_3d( vbuff,   vBx, vBy, LIGHTING_Z_LIMIT );
    vertex_position_3d( vbuff,   vBx, vBy, 0 );
    
    vertex_position_3d( vbuff,   vAx, vAy, 0 );
    vertex_position_3d( vbuff,   vAx, vAy, LIGHTING_Z_LIMIT );
    vertex_position_3d( vbuff,   vBx, vBy, LIGHTING_Z_LIMIT );
    
}

d3d_transform_set_identity();
