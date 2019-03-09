//  Build occluder geometry and render lights, with their shadows, to a screen-space lighting surface.
//  Should be called in one object per room, the same object that called lighting_start().
//  This script changes the gpu_set_cullmode() / gpu_set_zwriteenable() / gpu_set_ztestenable() render states!
//  
//  return: Nothing
//  
//  March 2019
//  @jujuadams
//  Based on the YAILSE system by xot (John Leffingwell) of gmlscripts.com
//  Additional contributions from Alexey Mihailov (@LexPest)
//  
//  This code and engine are provided under the Creative Commons "Attribution - NonCommerical - ShareAlike" international license.
//  https://creativecommons.org/licenses/by-nc-sa/4.0/



///////////Discover camera variables
var _camera_l  = camera_get_view_x( lighting_camera );
var _camera_t  = camera_get_view_y( lighting_camera );
var _camera_w  = camera_get_view_width( lighting_camera );
var _camera_h  = camera_get_view_height( lighting_camera );
var _camera_r  = _camera_l + _camera_w;
var _camera_b  = _camera_t + _camera_h;
var _camera_cx = _camera_l + 0.5*_camera_w;
var _camera_cy = _camera_t + 0.5*_camera_h;

var _camera_exp_l = _camera_l - LIGHTING_DYNAMIC_BORDER;
var _camera_exp_t = _camera_t - LIGHTING_DYNAMIC_BORDER;
var _camera_exp_r = _camera_r + LIGHTING_DYNAMIC_BORDER;
var _camera_exp_b = _camera_b + LIGHTING_DYNAMIC_BORDER;



///////////One-time construction of a triangle to wipe the z-buffer
//Using textures (rather than untextured) saves on shader_set() overhead... likely a trade-off depending on the GPU
if ( vbf_zbuffer_reset == noone ) {
	
    vbf_zbuffer_reset = vertex_create_buffer();
    vertex_begin( vbf_zbuffer_reset, vft_3d_textured );
	
	vertex_position_3d( vbf_zbuffer_reset,           0,           0, 0 ); vertex_colour( vbf_zbuffer_reset, c_black, 1 ); vertex_texcoord( vbf_zbuffer_reset, global.lighting_black_u, global.lighting_black_v );
	vertex_position_3d( vbf_zbuffer_reset, 2*_camera_w,           0, 0 ); vertex_colour( vbf_zbuffer_reset, c_black, 1 ); vertex_texcoord( vbf_zbuffer_reset, global.lighting_black_u, global.lighting_black_v );
	vertex_position_3d( vbf_zbuffer_reset,           0, 2*_camera_h, 0 ); vertex_colour( vbf_zbuffer_reset, c_black, 1 ); vertex_texcoord( vbf_zbuffer_reset, global.lighting_black_u, global.lighting_black_v );
	
    vertex_end( vbf_zbuffer_reset );
	vertex_freeze( vbf_zbuffer_reset );
	
}



///////////One-time construction of the static occluder geometry
if ( vbf_static_shadows == noone ) {
	
    //Create a new vertex buffer
    vbf_static_shadows = vertex_create_buffer();
    
    //Add static shadow caster vertices to the relevant vertex buffer
    vertex_begin( vbf_static_shadows, vft_3d_textured );
    with ( obj_static_occluder ) __lighting_add_occlusion( other.vbf_static_shadows );
    vertex_end( vbf_static_shadows );
	
    //Freeze this buffer for speed boosts later on (though only if we have vertices in this buffer)
    if ( vertex_get_number( vbf_static_shadows ) > 0 ) vertex_freeze( vbf_static_shadows );
	
}



///////////Refresh the dynamic occluder geometry
//Try to keep dynamic objects limited.
if ( LIGHTING_REUSE_DYNAMIC_BUFFER ) {
	if ( vbf_dynamic_shadows == noone ) vbf_dynamic_shadows = vertex_create_buffer();
} else {
	if ( vbf_dynamic_shadows != noone ) vertex_delete_buffer( vbf_dynamic_shadows );
	vbf_dynamic_shadows = vertex_create_buffer();
}

//Add dynamic occluder vertices to the relevant vertex buffer
vertex_begin( vbf_dynamic_shadows, vft_3d_textured );
with ( obj_dynamic_occluder ) {
    light_on_screen = visible and rectangle_in_rectangle_custom( bbox_left, bbox_top,
	                                                             bbox_right, bbox_bottom,
								                                 _camera_exp_l, _camera_exp_t,
													             _camera_exp_r, _camera_exp_b );
	if ( light_on_screen ) __lighting_add_occlusion( other.vbf_dynamic_shadows );
}
vertex_end( vbf_dynamic_shadows );



///////////Render out lights and shadows for each deferred light in the viewport
if ( LIGHTING_ENABLE_DEFERRED ) {
    
    gpu_set_cullmode( lighting_culling );
    with( obj_par_light ) {
    	if ( !light_deferred ) continue;
        
        light_on_screen = visible and rectangle_in_rectangle_custom( x - light_w_half, y - light_h_half,
                                                                     x + light_w_half, y + light_h_half,
    								                                 _camera_l, _camera_t, _camera_r, _camera_b );
	    
        //If this light is ready to be drawn...
        if ( light_on_screen ) {
            
            surface_set_target( srf_light );
			    
    	        //Draw the light sprite
    			shader_set( shd_pass_through );
    	        draw_sprite_ext( sprite_index, image_index,    light_w_half, light_h_half,    1, 1, 0,    merge_colour( c_black, image_blend, image_alpha ), 1 );
			    
    	        //Magical projection!
    			shader_set( shd_snap_vertex );
    			matrix_set( matrix_view, matrix_build_lookat( x, y, light_w,   x, y, 0,   dsin( -image_angle ), -dcos( -image_angle ), 0 ) );
    			matrix_set( matrix_projection, matrix_build_projection_perspective( image_xscale, image_yscale, 1, 16000 ) );
		        
    	        //Tell the GPU to render the shadow geometry
    	        vertex_submit( other.vbf_static_shadows,  pr_trianglelist, -1 );
    	        vertex_submit( other.vbf_dynamic_shadows, pr_trianglelist, -1 );
			    
            surface_reset_target();
            
        }
    }
    
    gpu_set_cullmode( cull_noculling );
    shader_reset();
}



///////////Set GPU properties
//Use a cumulative blend mode to add lights together
if ( LIGHTING_BM_MAX ) gpu_set_blendmode_ext_sepalpha( bm_one, bm_inv_src_colour, bm_zero, bm_one ) else gpu_set_blendmode( bm_add );
gpu_set_cullmode( lighting_culling );
gpu_set_ztestenable( true );
gpu_set_zwriteenable( true );

var _vbf_zbuffer_reset   = vbf_zbuffer_reset;
var _vbf_static_shadows  = vbf_static_shadows;
var _vbf_dynamic_shadows = vbf_dynamic_shadows;

//Create composite lighting surface
srf_lighting = surface_check( srf_lighting, _camera_w, _camera_h );
surface_set_target( srf_lighting );
    
    //var _view_matrix = matrix_build_lookat( _camera_w/2, _camera_h/2, -16000,   _camera_w/2, _camera_h/2, 0,   0, 1, 0 );
    //var _view_matrix = [            1,            0,     0, 0,                   // [            1,            0,         0, 0, 
    //                                0,            1,     0, 0,                   //              0,            1,         0, 0, 
    //                                0,            0,     1, 0,                   //              0,            0,         1, 0, 
    //                     -_camera_w/2, -_camera_h/2, 16000, 1 ];                 //   -_camera_w/2, -_camera_h/2, -camera_z, 1 ]
    
    //var _proj_matrix =  matrix_build_projection_ortho( _camera_w, -_camera_h, 1, 32000 );
    //var _proj_matrix = [ 2/_camera_w,           0,           0,  0,             // [ 2/_camera_w,           0,                      0, 0,
    //                               0, 2/_camera_h,           0,  0,             //             0, 2/_camera_h,                      0, 0,
    //                               0,           0,  1/(32000-1), 0,             //             0,           0,       1/(z_far-z_near), 0,
    //                               0,           0, -1/(32000-1), 1 ];           //             0,           0, -z_near/(z_far-z_near), 1 ]
    
    //var _vp_matrix = matrix_multiply( _new_view, _new_proj );
    //var _vp_matrix = [ 2/_camera_w,           0,           0, 0,                  // [ 2/_camera_w,            0,                                   0, 0,
    //                             0, 2/_camera_h,           0, 0,                  //             0, -2/_camera_h,                                   0, 0,
    //                             0,           0,     1/31999, 0,                  //             0,            0,                    1/(z_far-z_near), 0,
    //                            -1,           1, 15999/31999, 1 ];                //            -1,            1, (-camera_z - z_near)/(z_far-z_near), 1 ]
    
    //Ultimately, we can use the following projection matrix, with a bit of a fiddle for the z-axis:
    if (LIGHTING_FLIP_CAMERA_Y)
    {
        //DirectX platforms want the Y-axis flipped
        var _vp_matrix = [ 2/_camera_w,            0, 0, 0,
                                     0, -2/_camera_h, 0, 0,
                                     0,            0, 0, 0,
                                    -1,            1, 1, 1 ];
    }
    else
    {
        var _vp_matrix = [ 2/_camera_w,            0, 0, 0,
                                     0,  2/_camera_h, 0, 0,
                                     0,            0, 0, 0,
                                    -1,           -1, 1, 1 ];
    }
    
    //We set the view matrix to identity to allow us to use our custom projection matrix
    matrix_set( matrix_view, [1,0,0,0,  0,1,0,0,  0,0,1,0,  0,0,0,1] );
    matrix_set( matrix_projection, _vp_matrix );
	
    //Clear the surface with the ambient colour
    draw_clear_alpha( lighting_ambient_colour, 0 );
	
	//Calculate some transform coefficients
	var _inv_camera_w = 2/_camera_w;
	var _inv_camera_h = 2/_camera_h;
    
	var _transformed_cam_x = _camera_cx*_inv_camera_w;
	var _transformed_cam_y = _camera_cy*_inv_camera_h;
	
	//Pre-build a custom projection matrix
	//[8] and [9] are set per light
	var _proj_matrix = [      _inv_camera_w,                   0, 0,  0,
				                          0,       _inv_camera_h, 0,  0,
							      undefined,           undefined, 0, -1,
						-_transformed_cam_x, -_transformed_cam_y, 0,  1 ];
	
    // xOut = (x - z*(camX - lightX) - camX) / camW
    // yOut = (y - z*(camY - lightY) - camY) / camH
    // zOut = 0
    //
    // Perspective correction:
    // xOut /= 1-z
    // yOut /= 1-z
    
	///////////Iterate over all non-deferred lights...
    if ( true )
    {
    	gpu_set_zfunc( cmpfunc_always );
    	gpu_set_colorwriteenable( false, false, false, false );
    	vertex_submit( _vbf_zbuffer_reset, pr_trianglelist, global.lighting_black_texture ); //Reset the zbuffer
        
        if ( keyboard_check_pressed( ord( "J" ) ) )
        {
            show_debug_message( "clear triangle=" + string( matrix_transform_vertex( _vp_matrix, 0, 0, 0 ) ) );
        }
        
        with ( obj_par_light )
        {
        	if ( light_deferred ) continue;
		    
    	    light_on_screen = visible && rectangle_in_rectangle_custom( x - light_w_half, y - light_h_half,
    	                                                                x + light_w_half, y + light_h_half,
    									                                _camera_l, _camera_t, _camera_r, _camera_b );
		    
    		//If this light is active, do some drawing
    		if ( light_on_screen )
            {
    			//Draw shadow stencil
    			gpu_set_zfunc( cmpfunc_always );
    			gpu_set_colorwriteenable( false, false, false, false );
                shader_set( LIGHTING_STENCIL_SHADER );
				    
    				vertex_submit( _vbf_zbuffer_reset, pr_trianglelist, global.lighting_black_texture ); //Reset the zbuffer
                    if ( keyboard_check_pressed( ord( "J" ) ) ) show_debug_message( matrix_transform_vertex( _vp_matrix, 0, 0, 0 ) );
                
    			_proj_matrix[8] = _transformed_cam_x - x*_inv_camera_w;
    			_proj_matrix[9] = _transformed_cam_y - y*_inv_camera_h;
                
                if ( keyboard_check_pressed( ord( "J" ) ) )
                {
                    show_debug_message( matrix_transform_vertex( _proj_matrix, mouse_x, mouse_y, 0 ) );
                    show_debug_message( matrix_transform_vertex_full( _proj_matrix, mouse_x, mouse_y, 3, 1 ) );
                }
                
    			matrix_set( matrix_projection, _proj_matrix );
    			gpu_set_zfunc( cmpfunc_lessequal );
				    
    				vertex_submit( _vbf_static_shadows,  pr_trianglelist, global.lighting_black_texture );
    				vertex_submit( _vbf_dynamic_shadows, pr_trianglelist, global.lighting_black_texture );
				    
    			//Draw light sprite
    			gpu_set_zfunc( cmpfunc_lessequal );
    			gpu_set_colorwriteenable( true, true, true, true );
                shader_reset();
				matrix_set( matrix_projection, _vp_matrix );
                
    				draw_sprite_ext( sprite_index, image_index,
    				                 x - _camera_l, y - _camera_t,
    								 image_xscale, image_yscale, image_angle,
    								 image_blend, image_alpha );
    		}
    	}
    	shader_reset();
    }
    else
    {
        #region Old method
        
        with ( obj_par_light )
        {
        	if ( light_deferred ) continue;
		    
    	    light_on_screen = visible and rectangle_in_rectangle_custom( x - light_w_half, y - light_h_half,
    	                                                                 x + light_w_half, y + light_h_half,
    									                                 _camera_l, _camera_t, _camera_r, _camera_b );
		    
    		//If this light is active, do some drawing
    		if ( light_on_screen )
            {
    			//Draw shadow stencil
    			shader_set( shd_shadow );
    			gpu_set_zfunc( cmpfunc_always );
    			gpu_set_colorwriteenable( false, false, false, false );
				    
    				vertex_submit( _vbf_zbuffer_reset, pr_trianglelist, global.lighting_black_texture ); //Reset the zbuffer
                    
    				_proj_matrix[8] = -x*_inv_camera_w + _transformed_cam_x;
    				_proj_matrix[9] =  y*_inv_camera_h - _transformed_cam_y;
    				matrix_set( matrix_projection, _proj_matrix );
				    
    				vertex_submit( _vbf_static_shadows,  pr_trianglelist, global.lighting_black_texture );
    				vertex_submit( _vbf_dynamic_shadows, pr_trianglelist, global.lighting_black_texture );
				    
    			//Draw light sprite
    			shader_reset();
    			gpu_set_zfunc( cmpfunc_lessequal );
    			gpu_set_colorwriteenable( true, true, true, true );
				    
    				matrix_set( matrix_projection, _vp_matrix );
    				draw_sprite_ext( sprite_index, image_index,
    				                 x - _camera_l, y - _camera_t,
    								 image_xscale, image_yscale, image_angle,
    								 image_blend, image_alpha );
    		}
    	}
        
        #endregion
    }
	
    //Reset GPU properties
    gpu_set_cullmode( cull_noculling );
    gpu_set_ztestenable( false );
    gpu_set_zwriteenable( false );
    
    
    
    ///////////Add deferred lights to composite lighting surface
    if ( LIGHTING_ENABLE_DEFERRED ) {
    
        //Use a cumulative blend mode to add lights together
    	if ( LIGHTING_BM_MAX ) gpu_set_blendmode( bm_max ) else gpu_set_blendmode( bm_add );
        with ( obj_par_light ) {
    		if ( light_deferred && light_on_screen ) {
    			var _sin = -dsin( image_angle );
    			var _cos =  dcos( image_angle );
    			var _x = image_xscale*light_w_half*_cos - image_yscale*light_h_half*_sin;
    			var _y = image_xscale*light_w_half*_sin + image_yscale*light_h_half*_cos;
    			draw_surface_ext( srf_light, floor( x - _x - _camera_l + 0.5 ), floor( y - _y - _camera_t + 0.5 ), image_xscale, image_yscale, image_angle, c_white, 1 );
    		}
    	}
        gpu_set_blendmode( bm_normal );
    
    }
    
surface_reset_target();



///////////Put the composite surface onto the screen
gpu_set_blendmode_ext( bm_dest_color, bm_zero );
draw_surface( srf_lighting, _camera_l, _camera_t );
gpu_set_blendmode( bm_normal );