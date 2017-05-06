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

var _old_culling      = gpu_get_cullmode();
var _old_world_matrix = matrix_get( matrix_world );
var _old_view_matrix  = matrix_get( matrix_view );
var _old_proj_matrix  = matrix_get( matrix_projection );

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



///////////One-time construction of the static shadow-casting geometry
if ( vbf_static_shadows == noone ) {

    //Create a new vertex buffer
    vbf_static_shadows = vertex_create_buffer();
    
    //Add static shadow caster vertices to the relevant vertex buffer
    vertex_begin( vbf_static_shadows, vft_shadow_geometry );
	
	var _vbuff = vbf_static_shadows;
	
    with ( obj_static_occluder ) _lighting_add_occlusion( other.vbf_static_shadows );
	
    vertex_position_3d( _vbuff,  -0.5, -0.5, 1 ); vertex_colour( _vbuff,   c_white, 1 ); vertex_texcoord( _vbuff, 0, 0 );
    vertex_position_3d( _vbuff,   0.5, -0.5, 1 ); vertex_colour( _vbuff,   c_white, 1 ); vertex_texcoord( _vbuff, 1, 0 );
    vertex_position_3d( _vbuff,  -0.5,  0.5, 1 ); vertex_colour( _vbuff,   c_white, 1 ); vertex_texcoord( _vbuff, 0, 1 );
    
    vertex_position_3d( _vbuff,   0.5, -0.5, 1 ); vertex_colour( _vbuff,   c_white, 1 ); vertex_texcoord( _vbuff, 1, 0 );
    vertex_position_3d( _vbuff,   0.5,  0.5, 1 ); vertex_colour( _vbuff,   c_white, 1 ); vertex_texcoord( _vbuff, 1, 1 );
    vertex_position_3d( _vbuff,  -0.5,  0.5, 1 ); vertex_colour( _vbuff,   c_white, 1 ); vertex_texcoord( _vbuff, 0, 1 );
	
    vertex_end( vbf_static_shadows );
    
	buf_shadows = buffer_create_from_vertex_buffer( vbf_static_shadows, buffer_grow, 1 );
	static_shadows_index = buffer_get_size( buf_shadows );
	
    //Freeze this buffer for speed boosts later on (though only if we have vertices in this buffer)
    if ( vertex_get_number( vbf_static_shadows ) > 0 ) vertex_freeze( vbf_static_shadows );
	
}



///////////Refresh the dynamic geometry
//This is really slow so try to keep dynamic objects limited.

if ( vbf_dynamic_shadows != noone ) vertex_delete_buffer( vbf_dynamic_shadows );
vbf_dynamic_shadows = vertex_create_buffer();

//Add dynamic shadow caster vertices to the relevant vertex buffer
vertex_begin( vbf_dynamic_shadows, vft_shadow_geometry );
with ( obj_dynamic_occluder ) {
    on_screen = visible and rectangle_in_rectangle( bbox_left, bbox_top,
	                                                bbox_right, bbox_bottom,
								                    _camera_exp_l, _camera_exp_t,
													_camera_exp_r, _camera_exp_b );
	if ( on_screen or true ) _lighting_add_occlusion( other.vbf_dynamic_shadows );
	
}
vertex_end( vbf_dynamic_shadows );

var _buffer = buffer_create_from_vertex_buffer( vbf_dynamic_shadows, buffer_grow, 1 );
buffer_copy( _buffer, 0, buffer_get_size( _buffer ), buf_shadows, static_shadows_index );
buffer_delete( _buffer );

var _all_shadows_vertex_buffer = vertex_create_buffer_from_buffer( buf_shadows, vft_shadow_geometry );



///////////Create composite lighting surface
srf_lighting = surface_check( srf_lighting, _camera_w, _camera_h );
surface_set_target( srf_lighting );

    //Clear the surface with the ambient colour
    draw_clear( lighting_ambient_colour );
	
    //Use a cumulative blend mode to add lights together
	shader_set( shd_lighting );
    gpu_set_blendmode( bm_add );
	gpu_set_ztestenable( true );
	gpu_set_colorwriteenable( true, true, true, false );
	gpu_set_cullmode( lighting_culling );
	matrix_set( matrix_projection, matrix_build_projection_perspective( _camera_w, _camera_h, 1, 16000 ) );
	
	var _index = 0;
    with ( obj_par_light ) {
		
	    on_screen = visible and rectangle_in_rectangle( x - light_w_half, y - light_h_half,
	                                                    x + light_w_half, y + light_h_half,
									                    _camera_l, _camera_t, _camera_r, _camera_b );
		
		if ( on_screen ) {
			
			var _uvs = sprite_get_uvs( sprite_index, image_index );
			shader_set_uniform_f( shader_get_uniform( shd_lighting, "u_vUV" ), _uvs[0], _uvs[1], _uvs[2]-_uvs[0], _uvs[3]-_uvs[1] );
			shader_set_uniform_f( shader_get_uniform( shd_lighting, "u_vLightColour" ), colour_get_red(   image_blend )/255,
			                                                                            colour_get_green( image_blend )/255,
																						colour_get_blue(  image_blend )/255,
																						image_alpha );
			shader_set_uniform_f( shader_get_uniform( shd_lighting, "u_vTranslate" ), 2*( x - _camera_cx ) / _camera_w, -2*( y - _camera_cy ) / _camera_h, _index );
			
			var _sin = dsin( image_angle );
			var _cos = dcos( image_angle );
			var _matrix = [ light_w*image_xscale*_cos, -light_w*image_xscale*_sin, 0, 0,
			                light_h*image_yscale*_sin,  light_h*image_yscale*_cos, 0, 0,
							                0,                  0, 1, 0,
							                x,                  y, 0, 1 ];
								
			matrix_set( matrix_world, _matrix );
			matrix_set( matrix_view, matrix_build_lookat( x, y, 1,   x, y, 0,   0, -1, 0 ) );
			
			
			
			vertex_submit( _all_shadows_vertex_buffer,  pr_trianglelist, sprite_get_texture( sprite_index, image_index ) );
			_index += 0.01;
			
		}
	}
	
	shader_reset();
	gpu_set_ztestenable( false );
	gpu_set_blendmode( bm_normal );
	gpu_set_colorwriteenable( true, true, true, true );
	gpu_set_cullmode( cull_noculling );

surface_reset_target();



///////////Reset prior GPU properties
gpu_set_cullmode( _old_culling );
matrix_set( matrix_world     , _old_world_matrix );
matrix_set( matrix_view      , _old_view_matrix  );
matrix_set( matrix_projection, _old_proj_matrix  );
vertex_delete_buffer( _all_shadows_vertex_buffer );



///////////Put the composite surface onto the screen
gpu_set_blendmode_ext( bm_dest_color, bm_zero );
draw_surface( srf_lighting, _camera_l, _camera_t );
gpu_set_blendmode( bm_normal );