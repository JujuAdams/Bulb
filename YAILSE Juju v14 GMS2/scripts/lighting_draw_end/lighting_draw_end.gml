/// @param default_culling
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

var _default_culling = argument0;

//Establish camera properties
var _camera_l = camera_get_view_x( lighting_camera );
var _camera_t = camera_get_view_y( lighting_camera );
var _camera_w = camera_get_view_width( lighting_camera );
var _camera_h = camera_get_view_height( lighting_camera );
var _camera_r = _camera_l + _camera_w;
var _camera_b = _camera_t + _camera_h;



///////////One-time construction of the static shadow-casting geometry
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



///////////Refresh the dynamic geometry
//This is really slow so try to keep dynamic objects limited.
if ( vbf_dynamic_shadows != noone ) vertex_delete_buffer( vbf_dynamic_shadows );
vbf_dynamic_shadows = vertex_create_buffer();

//Add dynamic shadow caster vertices to the relevant vertex buffer
vertex_begin( vbf_dynamic_shadows, vft_shadow_geometry );
with ( obj_dynamic_block ) {
    on_screen = visible and rectangle_in_rectangle( bbox_left, bbox_top, bbox_right, bbox_bottom,
								                    _camera_l, _camera_t, _camera_r, _camera_b );
	if ( on_screen ) _lighting_add_occlusion( other.vbf_dynamic_shadows );
}
vertex_end( vbf_dynamic_shadows );



///////////Render out lights and shadows for each light in the viewport
gpu_set_cullmode( lighting_culling );
with ( obj_par_light ) {
	
    on_screen = visible and rectangle_in_rectangle( x - light_w_half, y - light_h_half,
                                                    x + light_w_half, y + light_h_half,
								                    _camera_l, _camera_t, _camera_r, _camera_b );
	
    //If this light is ready to be drawn...
    if ( on_screen ) {
        
        surface_set_target( srf_light );
        
	        //draw_clear() is expensive. Only clear if the light map sprite is maybe not going to cover the entire surface.
	        if ( image_angle != 0 ) or ( abs( image_xscale ) < light_max_xscale ) or ( abs( image_yscale ) < light_max_yscale ) draw_clear( c_black );
        
	        //Draw the light sprite
	        draw_sprite_ext( sprite_index, image_index,    light_w_half, light_h_half,    image_xscale, image_yscale, image_angle,    merge_colour( c_black, image_blend, image_alpha ), 1 );
        
	        //Magical projection!
			matrix_set( matrix_view, matrix_build_lookat( x, y, light_w,   x, y, 0,   0, -1, 0 ) );
			matrix_set( matrix_projection, matrix_build_projection_perspective( 1, light_h/light_w, 1, 32000 ) );
		
	        //Tell the GPU to render the shadow geometry
	        vertex_submit( other.vbf_static_shadows,  pr_trianglelist, -1 );
	        vertex_submit( other.vbf_dynamic_shadows, pr_trianglelist, -1 );
			
        surface_reset_target();
        
    }
}

gpu_set_cullmode( _default_culling );



///////////Create composite lighting surface
srf_lighting = surface_check( srf_lighting, _camera_w, _camera_h );
surface_set_target( srf_lighting );
	
    //Clear the surface with the ambient colour
    draw_clear( lighting_ambient_colour );
    
    //Use a cumulative blend mode to add lights together
    gpu_set_blendmode( bm_max );
    with ( obj_par_light ) if ( on_screen ) draw_surface( srf_light, x - light_w_half - _camera_l, y - light_h_half - _camera_t );
    gpu_set_blendmode( bm_normal );

surface_reset_target();



///////////Put the composite surface onto the screen
gpu_set_blendmode_ext( bm_dest_color, bm_zero );
draw_surface( srf_lighting, _camera_l, _camera_t );
gpu_set_blendmode( bm_normal );