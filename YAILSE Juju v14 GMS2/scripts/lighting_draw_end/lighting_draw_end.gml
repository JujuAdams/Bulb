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



var _camera_l  = camera_get_view_x( lighting_camera );
var _camera_t  = camera_get_view_y( lighting_camera );
var _camera_w  = camera_get_view_width( lighting_camera );
var _camera_h  = camera_get_view_height( lighting_camera );
var _camera_r  = _camera_l + _camera_w;
var _camera_b  = _camera_t + _camera_h;
var _camera_cx = _camera_l + 0.5*_camera_w;
var _camera_cy = _camera_t + 0.5*_camera_h;

var _camera_exp_l = _camera_l - LIGHTING_DYNAMIC_INCLUSION;
var _camera_exp_t = _camera_t - LIGHTING_DYNAMIC_INCLUSION;
var _camera_exp_r = _camera_r + LIGHTING_DYNAMIC_INCLUSION;
var _camera_exp_b = _camera_b + LIGHTING_DYNAMIC_INCLUSION;



///////////One-time construction of a rectangle to wipe the z-buffer
if ( vbf_zbuffer_reset == noone ) {
	
    vbf_zbuffer_reset = vertex_create_buffer();
    vertex_begin( vbf_zbuffer_reset, vft_3d_textured );
	
	vertex_position_3d( vbf_zbuffer_reset,         0,         0, LIGHTING_ZFAR-1 ); vertex_colour( vbf_zbuffer_reset, c_black, 0 ); vertex_texcoord( vbf_zbuffer_reset, global.lighting_black_u, global.lighting_black_v );
	vertex_position_3d( vbf_zbuffer_reset, _camera_w,         0, LIGHTING_ZFAR-1 ); vertex_colour( vbf_zbuffer_reset, c_black, 0 ); vertex_texcoord( vbf_zbuffer_reset, global.lighting_black_u, global.lighting_black_v );
	vertex_position_3d( vbf_zbuffer_reset,         0, _camera_h, LIGHTING_ZFAR-1 ); vertex_colour( vbf_zbuffer_reset, c_black, 0 ); vertex_texcoord( vbf_zbuffer_reset, global.lighting_black_u, global.lighting_black_v );
	
	vertex_position_3d( vbf_zbuffer_reset, _camera_w,         0, LIGHTING_ZFAR-1 ); vertex_colour( vbf_zbuffer_reset, c_black, 0 ); vertex_texcoord( vbf_zbuffer_reset, global.lighting_black_u, global.lighting_black_v );
	vertex_position_3d( vbf_zbuffer_reset, _camera_w, _camera_h, LIGHTING_ZFAR-1 ); vertex_colour( vbf_zbuffer_reset, c_black, 0 ); vertex_texcoord( vbf_zbuffer_reset, global.lighting_black_u, global.lighting_black_v );
	vertex_position_3d( vbf_zbuffer_reset,         0, _camera_h, LIGHTING_ZFAR-1 ); vertex_colour( vbf_zbuffer_reset, c_black, 0 ); vertex_texcoord( vbf_zbuffer_reset, global.lighting_black_u, global.lighting_black_v );
	
    vertex_end( vbf_zbuffer_reset );
	vertex_freeze( vbf_zbuffer_reset );
	
}



///////////One-time construction of the static shadow-casting geometry
if ( vbf_static_shadows == noone ) {
	
    //Create a new vertex buffer
    vbf_static_shadows = vertex_create_buffer();
    
    //Add static shadow caster vertices to the relevant vertex buffer
    vertex_begin( vbf_static_shadows, vft_3d_textured );
    with ( obj_static_occluder ) _lighting_add_occlusion( other.vbf_static_shadows );
    vertex_end( vbf_static_shadows );
	
    //Freeze this buffer for speed boosts later on (though only if we have vertices in this buffer)
    if ( vertex_get_number( vbf_static_shadows ) > 0 ) vertex_freeze( vbf_static_shadows );
	
}



///////////Refresh the dynamic geometry
//Try to keep dynamic objects limited.
if ( vbf_dynamic_shadows != noone ) vertex_delete_buffer( vbf_dynamic_shadows );
vbf_dynamic_shadows = vertex_create_buffer();

//Add dynamic shadow caster vertices to the relevant vertex buffer
vertex_begin( vbf_dynamic_shadows, vft_3d_textured );
with ( obj_dynamic_occluder ) {
    on_screen = visible and rectangle_in_rectangle( bbox_left, bbox_top,
	                                                bbox_right, bbox_bottom,
								                    _camera_exp_l, _camera_exp_t,
													_camera_exp_r, _camera_exp_b );
	if ( on_screen ) _lighting_add_occlusion( other.vbf_dynamic_shadows );
}
vertex_end( vbf_dynamic_shadows );



///////////Create composite lighting surface
srf_lighting = surface_check( srf_lighting, _camera_w, _camera_h );
surface_set_target( srf_lighting );
	
	//Grab the default view/projection matrices for use later
	var _surface_view_matrix = matrix_get( matrix_view );
	var _surface_proj_matrix = matrix_get( matrix_projection );
	
    //Clear the surface with the ambient colour
    draw_clear( lighting_ambient_colour );
	
    //Use a cumulative blend mode to add lights together
    gpu_set_blendmode( bm_max );
	gpu_set_cullmode( lighting_culling );
	gpu_set_ztestenable( true );
	gpu_set_zwriteenable( true );
	shader_set( shd_pass_through );
	
	//Build our shadow-casting projection matrix
	var _camera_proj_matrix = matrix_build_projection_perspective( _camera_w, _camera_h, 1, LIGHTING_ZFAR );
	
	//Build our transform matrix to put shadows back into screen-space
	//Indexes 12+13 are set per light. Index 10 sets shadow shapes to the foreground of the scene
	var _transform_matrix = [ 1, 0, 0, 0,
				              0, 1, 0, 0,
							  0, 0, 0, 0,
							  0, 0, 0, 1 ];
	
    with ( obj_par_light ) {
		
	    on_screen = visible and rectangle_in_rectangle( x - light_w_half, y - light_h_half,
	                                                    x + light_w_half, y + light_h_half,
									                    _camera_l, _camera_t, _camera_r, _camera_b );
		
		if ( on_screen ) {
			
			//shader_set( shd_shadow );
			gpu_set_zfunc( cmpfunc_always );
			gpu_set_colorwriteenable( false, false, false, false );
				
				vertex_submit( other.vbf_zbuffer_reset, pr_trianglelist, global.lighting_black_texture ); //Reset the zbuffer
				
				//This is actually a view*projection matrix.
				//Combining this into one place (given that the world matrix is an identity) reduces matrix_set() calls
				matrix_set( matrix_view, matrix_multiply( matrix_build_lookat( x, y, 1,   x, y, 0,   0, -1, 0 ), _camera_proj_matrix ) );
				_transform_matrix[12] =  ( x - _camera_cx ) / ( 0.5*_camera_w );
				_transform_matrix[13] = -( y - _camera_cy ) / ( 0.5*_camera_h );
				matrix_set( matrix_projection, _transform_matrix ); //Transform from light-space to screen-space
				
				vertex_submit( other.vbf_static_shadows,  pr_trianglelist, global.lighting_black_texture );
				vertex_submit( other.vbf_dynamic_shadows, pr_trianglelist, global.lighting_black_texture );
				
			//shader_set( shd_pass_through );
			gpu_set_zfunc( cmpfunc_lessequal );
			gpu_set_colorwriteenable( true, true, true, true );
				matrix_set( matrix_view, _surface_view_matrix );
				matrix_set( matrix_projection, _surface_proj_matrix );
				draw_sprite_ext( sprite_index, image_index, x - _camera_l, y - _camera_t, image_xscale, image_yscale, image_angle, image_blend, image_alpha );
				
		}
	}
	
	///////////Reset GPU properties
	shader_reset();
	gpu_set_blendmode( bm_normal );
	gpu_set_cullmode( cull_noculling );
	gpu_set_ztestenable( false );
	gpu_set_zwriteenable( false );

surface_reset_target();



///////////Put the composite surface onto the screen
gpu_set_blendmode_ext( bm_dest_color, bm_zero );
draw_surface( srf_lighting, _camera_l, _camera_t );
gpu_set_blendmode( bm_normal );