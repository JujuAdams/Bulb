#define lighting_draw_end
///lighting_build( default culling )
//
//  Build shadow casting geometry and render lights, with their shadows, to a screen-space lighting surface.
//  Should be called in one object per room, the same object that called scr_lighting_start().
//  This script changes the d3d_set_culling() internal value!
//  
//  argument0: Culling value to be set after the script has ended.
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



//One-time construction of the static shadow-casting geometry
if ( vbf_static_shadows == noone ) {

    //Create a new vertex buffer
    vbf_static_shadows = vertex_create_buffer();
    
    //Add static shadow caster vertices to the relevant vertex buffer
    vertex_begin( vbf_static_shadows, vft_shadow_geometry );
    with ( obj_static_block ) _lighting_add_occlusion( other.vbf_static_shadows );
    vertex_end( vbf_static_shadows );
    
    //Freeze this buffer for speed boosts later on (though only if we have vertices in this buffer)
    if ( vertex_get_number( vbf_static_shadows ) > 0 ) vertex_freeze( vbf_static_shadows );
    
}

//--- Refresh the dynamic geometry
//This is really slow so try to keep dynamic objects limited.
if ( vbf_dynamic_shadows != noone ) vertex_delete_buffer( vbf_dynamic_shadows );
vbf_dynamic_shadows = vertex_create_buffer();

//Add dynamic shadow caster vertices to the relevant vertex buffer
vertex_begin( vbf_dynamic_shadows, vft_shadow_geometry );
with ( obj_dynamic_block ) if ( on_screen ) _lighting_add_occlusion( other.vbf_dynamic_shadows );
vertex_end( vbf_dynamic_shadows );



d3d_set_culling( lighting_self_lighting );
//For each light on the screen...
with ( obj_par_light ) {
    
    //If they're on screen...
    if ( on_screen ) {
        
        //Target the light's work surface
        surface_set_target( srf_light );
        
        //draw_clear() is expensive. Only clear if the light map sprite is maybe not going to cover the entire surface.
        if ( image_angle != 0 ) or ( abs( image_xscale ) < light_max_xscale ) or ( abs( image_yscale ) < light_max_yscale ) draw_clear( c_black );
        
        //Draw the light sprite
        draw_sprite_ext( sprite_index, image_index,    light_w_half, light_h_half,    image_xscale, image_yscale, image_angle,    merge_colour( c_black, image_blend, image_alpha ), 1 );
        
        //Magical projection!
        d3d_set_projection_perspective( x + light_w_half, y + light_h_half,   -light_w, -light_h,   180 );
        
        //Use fogging to force the pixel colour to black (but doesn't force the alpha, giving us relatively smooth shadow borders)
        d3d_set_fog( true, c_black, 0, 0 );
        
        //Tell the GPU to render the shadow geometry
        vertex_submit( other.vbf_static_shadows,  pr_trianglelist, -1 );
        vertex_submit( other.vbf_dynamic_shadows, pr_trianglelist, -1 );
        
        //Reset everything
        d3d_set_fog( false, c_black, 0, 0 );
        surface_reset_target();
        
    }
}
d3d_set_culling( argument0 );



//Create composite lighting surface
srf_lighting = surface_check( srf_lighting, view_wview[LIGHTING_VIEW], view_hview[LIGHTING_VIEW] );
surface_set_target( srf_lighting );
    
    //Clear the surface with the ambient colour
    draw_clear( lighting_ambient_colour );
    
    //Use a cumulative blend mode to add lights together
    draw_set_blend_mode( bm_max );
    with ( obj_par_light ) if ( on_screen ) draw_surface( srf_light, x - light_w_half - view_xview[LIGHTING_VIEW], y - light_h_half - view_yview[LIGHTING_VIEW] );
    draw_set_blend_mode( bm_normal );

surface_reset_target();



draw_set_blend_mode_ext( bm_dest_color, bm_zero );
draw_surface( srf_lighting, view_xview[LIGHTING_VIEW], view_yview[LIGHTING_VIEW] );
draw_set_blend_mode( bm_normal );

#define scr_lighting_add_occlusion
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