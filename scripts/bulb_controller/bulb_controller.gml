/// @jujuadams
/// Based on work by xot (John Leffingwell) of gmlscripts.com
///
/// @param camera
/// @param ambientColour
/// @param selfLighting
/// @param mode

enum BULB_MODE
{
    HARD_BM_ADD, //Basic hard shadows with z-buffer stenciling, using the typical bm_add blend mode
    HARD_BM_MAX, //As above, but using bm_max to reduce bloom
    SOFT_BM_ADD, //Soft shadows using bm_add
    __SIZE
}

function bulb_controller(_camera, _ambient_colour, _self_lighting, _mode) constructor
{
    //Assign the camera used to draw the lights
    camera = _camera;
    
    //Assign the ambient colour used for the darkest areas of the screen. This can be changed on the fly
    ambient_colour = _ambient_colour;
    
    //If culling is switched on, shadows will only be cast from the rear faces of occluders
    //This requires careful object placement as not to create weird graphical glitches
    self_lighting = _self_lighting;
    
    mode = _mode;
    
    partial_clear = true;
    
    force_deferred = false;
    
    //Initialise variables used and updated in bulb_build()
    static_vbuffer  = undefined; //Vertex buffer describing the geometry of static occluder objects
    dynamic_vbuffer = undefined; //As above but for dynamic shadow occluders. This is updated every step
    wipe_vbuffer    = undefined; //This vertex buffer is used to reset the z-buffer during accumulation of non-deferred lights
    surface         = undefined; //Screen-space surface for final accumulation of lights
    
    
    
    update = function()
    {
        ///////////Discover camera variables
        var _camera_l  = camera_get_view_x(camera);
        var _camera_t  = camera_get_view_y(camera);
        var _camera_w  = camera_get_view_width(camera);
        var _camera_h  = camera_get_view_height(camera);
        var _camera_r  = _camera_l + _camera_w;
        var _camera_b  = _camera_t + _camera_h;
        var _camera_cx = _camera_l + 0.5*_camera_w;
        var _camera_cy = _camera_t + 0.5*_camera_h;
        
        //Construct our wipe/static/dynamic vertex buffers
        update_vertex_buffers();
        
        //Go through all deferred lights and update their surfaces
        if (BULB_ALLOW_DEFERRED)
        {
            update_deferred_lights(_camera_l, _camera_t, _camera_r, _camera_b);
        }
        
        //Create accumulating lighting surface
        if ((surface == undefined)|| !surface_exists(surface))
        {
            surface = surface_create(_camera_w, _camera_h);
        }
        
        surface_set_target(surface);
    
        //Clear the surface with the ambient colour
        draw_clear(ambient_colour);
        
        //If we're not forcing deferred rendering everywhere, update those lights
        if (!force_deferred)
        {
            accumulate_nondeferred_lights(_camera_l, _camera_t, _camera_r, _camera_b, _camera_cx, _camera_cy, _camera_w, _camera_h);
        }
        
        //Accumulate all deferred lights
        if (BULB_ALLOW_DEFERRED || force_deferred)
        {
            accumulate_deferred_lights();
        }
        
        surface_reset_target();
    }
    
    draw = function()
    {
        draw_at(camera_get_view_x(camera), camera_get_view_y(camera));
    }
    
    /// @param x
    /// @param y
    draw_at = function(_x, _y)
    {
        if ((surface != undefined) && surface_exists(surface))
        {
            gpu_set_blendmode_ext(bm_dest_color, bm_zero);
            draw_surface(surface, _x, _y);
            gpu_set_blendmode(bm_normal);
        }
    }
    
    free_vertex_buffers = function()
    {
        if (wipe_vbuffer != undefined)
        {
            vertex_delete_buffer(wipe_vbuffer);
            wipe_vbuffer = undefined;
        }
        
        if (static_vbuffer != undefined)
        {
            vertex_delete_buffer(static_vbuffer);
            static_vbuffer = undefined;
        }
        
        if (dynamic_vbuffer != undefined)
        {
            vertex_delete_buffer(dynamic_vbuffer);
            dynamic_vbuffer = undefined;
        }
    }
    
    free_surface = function()
    {
        if (surface_exists(surface))
        {
            surface_free(surface);
            surface = undefined;
        }
    }
    
    free = function()
    {
        free_vertex_buffers();
        free_surface();
    }
    
    update_vertex_buffers = function()
    {
        ///////////Discover camera variables
        var _camera_w  = camera_get_view_width(camera);
        var _camera_h  = camera_get_view_height(camera);
        
        var _camera_l  = camera_get_view_x(camera);
        var _camera_t  = camera_get_view_y(camera);
        var _camera_r  = _camera_l + _camera_w;
        var _camera_b  = _camera_t + _camera_h;
        
        var _camera_exp_l = _camera_l - BULB_DYNAMIC_BORDER;
        var _camera_exp_t = _camera_t - BULB_DYNAMIC_BORDER;
        var _camera_exp_r = _camera_r + BULB_DYNAMIC_BORDER;
        var _camera_exp_b = _camera_b + BULB_DYNAMIC_BORDER;
        
        ///////////One-time construction of a triangle to wipe the z-buffer
        //Using textures (rather than untextured) saves on shader_set() overhead... likely a trade-off depending on the GPU
        if (wipe_vbuffer == undefined)
        {
            wipe_vbuffer = vertex_create_buffer();
            vertex_begin(wipe_vbuffer, global.__bulb_format_3d_colour);
            
            vertex_position_3d(wipe_vbuffer,           0,           0, 0); vertex_colour(wipe_vbuffer, c_black, 1);
            vertex_position_3d(wipe_vbuffer, 2*_camera_w,           0, 0); vertex_colour(wipe_vbuffer, c_black, 1);
            vertex_position_3d(wipe_vbuffer,           0, 2*_camera_h, 0); vertex_colour(wipe_vbuffer, c_black, 1);
            
            vertex_end(wipe_vbuffer);
            vertex_freeze(wipe_vbuffer);
        }
        
        ///////////One-time construction of the static occluder geometry
        if (static_vbuffer == undefined)
        {
            //Create a new vertex buffer
            static_vbuffer = vertex_create_buffer();
            var _static_vbuffer = static_vbuffer;
            
            //Add static shadow caster vertices to the relevant vertex buffer
            if (mode == BULB_MODE.SOFT_BM_ADD)
            {
                vertex_begin(static_vbuffer, global.__bulb_format_3d_texture);
                with (obj_static_occluder) __bulb_add_occlusion_soft(_static_vbuffer);
            }
            else
            {
                vertex_begin(static_vbuffer, global.__bulb_format_3d_colour);
                with (obj_static_occluder) __bulb_add_occlusion_hard(_static_vbuffer);
            }
            
            vertex_end(static_vbuffer);
            
            //Freeze this buffer for speed boosts later on (though only if we have vertices in this buffer)
            if (vertex_get_number(static_vbuffer) > 0) vertex_freeze(static_vbuffer);
        }
        
        ///////////Refresh the dynamic occluder geometry
        //Try to keep dynamic objects limited.
        if (BULB_REUSE_DYNAMIC_BUFFER)
        {
            if (dynamic_vbuffer == undefined) dynamic_vbuffer = vertex_create_buffer();
        }
        else
        {
            if (dynamic_vbuffer != undefined) vertex_delete_buffer(dynamic_vbuffer);
            dynamic_vbuffer = vertex_create_buffer();
        }
        
        var _dynamic_vbuffer = dynamic_vbuffer;
        
        //Add dynamic occluder vertices to the relevant vertex buffer
        if (mode == BULB_MODE.SOFT_BM_ADD)
        {
            vertex_begin(_dynamic_vbuffer, global.__bulb_format_3d_texture);
            with (obj_dynamic_occluder)
            {
                light_on_screen = visible && __bulb_rect_in_rect(bbox_left, bbox_top,
                                                                     bbox_right, bbox_bottom,
                                                                     _camera_exp_l, _camera_exp_t,
                                                                     _camera_exp_r, _camera_exp_b);
                if (light_on_screen) __bulb_add_occlusion_soft(_dynamic_vbuffer);
            }
        }
        else
        {
            vertex_begin(_dynamic_vbuffer, global.__bulb_format_3d_colour);
            with (obj_dynamic_occluder)
            {
                light_on_screen = visible && __bulb_rect_in_rect(bbox_left, bbox_top,
                                                                     bbox_right, bbox_bottom,
                                                                     _camera_exp_l, _camera_exp_t,
                                                                     _camera_exp_r, _camera_exp_b);
                if (light_on_screen) __bulb_add_occlusion_hard(_dynamic_vbuffer);
            }
        }
        
        vertex_end(_dynamic_vbuffer);
    }
    
    accumulate_nondeferred_lights = function(_camera_l, _camera_t, _camera_r, _camera_b, _camera_cx, _camera_cy, _camera_w, _camera_h)
    {
        #region Linear algebra
        
        //var _view_matrix = matrix_build_lookat(_camera_w/2, _camera_h/2, -16000,   _camera_w/2, _camera_h/2, 0,   0, 1, 0);
        
        //var _view_matrix = [           1,            0,     0, 0,                   // [            1,            0,         0, 0, 
        //                               0,            1,     0, 0,                   //              0,            1,         0, 0, 
        //                               0,            0,     1, 0,                   //              0,            0,         1, 0, 
        //                    -_camera_w/2, -_camera_h/2, 16000, 1 ];                 //   -_camera_w/2, -_camera_h/2, -camera_z, 1]
        
        //var _proj_matrix =  matrix_build_projection_ortho(_camera_w, -_camera_h, 1, 32000);
        
        //var _proj_matrix = [2/_camera_w,           0,           0,  0,             // [ 2/_camera_w,           0,                      0, 0,
        //                              0, 2/_camera_h,           0,  0,             //             0, 2/_camera_h,                      0, 0,
        //                              0,           0,  1/(32000-1), 0,             //             0,           0,       1/(z_far-z_near), 0,
        //                              0,           0, -1/(32000-1), 1 ];           //             0,           0, -z_near/(z_far-z_near), 1];
        
        //var _vp_matrix = matrix_multiply(_new_view, _new_proj);
        
        //var _vp_matrix = [2/_camera_w,           0,           0, 0,                  // [ 2/_camera_w,            0,                                   0, 0,
        //                            0, 2/_camera_h,           0, 0,                  //             0, -2/_camera_h,                                   0, 0,
        //                            0,           0,     1/31999, 0,                  //             0,            0,                    1/(z_far-z_near), 0,
        //                           -1,           1, 15999/31999, 1 ];                //            -1,            1, (-camera_z - z_near)/(z_far-z_near), 1];
        
        #endregion
        
        //Ultimately, we can use the following projection matrix
        if (BULB_FLIP_CAMERA_Y)
        {
            //DirectX platforms want the Y-axis flipped
            var _vp_matrix = [2/_camera_w,            0, 0, 0,
                                        0, -2/_camera_h, 0, 0,
                                        0,            0, 0, 0,
                                       -1,            1, 1, 1];
        }
        else
        {
            var _vp_matrix = [2/_camera_w,            0, 0, 0,
                                        0,  2/_camera_h, 0, 0,
                                        0,            0, 0, 0,
                                       -1,           -1, 1, 1];
        }
        
        //We set the view matrix to identity to allow us to use our custom projection matrix
        matrix_set(matrix_view, [1,0,0,0,  0,1,0,0,  0,0,1,0,  0,0,0,1]);
        matrix_set(matrix_projection, _vp_matrix);
            
        //If culling is switched on, shadows will only be cast from the rear faces of occluders
        //This requires careful object placement as not to create weird graphical glitches
        gpu_set_cullmode(self_lighting? cull_counterclockwise : cull_noculling);
            
        ///////////Iterate over all non-deferred lights...
        if (mode == BULB_MODE.SOFT_BM_ADD)
        {
            accumulate_nondeferred_soft_lights(_camera_l, _camera_t, _camera_r, _camera_b, _camera_cx, _camera_cy, _camera_w, _camera_h, _vp_matrix);
        }
        else
        {
            accumulate_nondeferred_hard_lights(_camera_l, _camera_t, _camera_r, _camera_b, _camera_cx, _camera_cy, _camera_w, _camera_h, _vp_matrix);
        }
            
        //Reset GPU properties
        shader_reset();
        gpu_set_colorwriteenable(true, true, true, true);
        gpu_set_cullmode(cull_noculling);
    }
    
    accumulate_nondeferred_soft_lights = function(_camera_l, _camera_t, _camera_r, _camera_b, _camera_cx, _camera_cy, _camera_w, _camera_h, _vp_matrix)
    {
        var _wipe_vbuffer    = wipe_vbuffer;
        var _static_vbuffer  = static_vbuffer;
        var _dynamic_vbuffer = dynamic_vbuffer;
        var _partial_clear   = partial_clear;
        
        //Calculate some transform coefficients
        var _inv_camera_w = 2/_camera_w;
        var _inv_camera_h = 2/_camera_h;
        if (BULB_FLIP_CAMERA_Y) _inv_camera_h = -_inv_camera_h;
        
        var _transformed_cam_x = _camera_cx*_inv_camera_w;
        var _transformed_cam_y = _camera_cy*_inv_camera_h;
        
        //Pre-build a custom projection matrix
        //[8] [9] [10] are set per light
        var _proj_matrix = [      _inv_camera_w,                   0,          0,  0,
                                              0,       _inv_camera_h,          0,  0,
                                      undefined,           undefined,  undefined, -1,
                            -_transformed_cam_x, -_transformed_cam_y,          0,  1];
        
        // xOut = (x - z*(camX - lightX) - camX) / camW
        // yOut = (y - z*(camY - lightY) - camY) / camH
        // zOut = 0
        
        with (obj_par_light)
        {
            if (light_deferred && BULB_ALLOW_DEFERRED) continue;
            
            light_on_screen = visible && __bulb_rect_in_rect(x - light_w_half, y - light_h_half,
                                                                 x + light_w_half, y + light_h_half,
                                                                 _camera_l, _camera_t, _camera_r, _camera_b);
            
            //If this light is active, do some drawing
            if (light_on_screen)
            {
                gpu_set_colorwriteenable(false, false, false, true);
                
                //Clear alpha channel
                gpu_set_blendmode(bm_subtract);
                
                if (_partial_clear)
                {
                    draw_sprite_ext(sprite_index, image_index,
                                    x - _camera_l, y - _camera_t,
                                    image_xscale, image_yscale, image_angle,
                                    c_black, 1);
                }
                else
                {
                    vertex_submit(_wipe_vbuffer, pr_trianglelist, -1);
                }
                
                //Render shadows
                shader_set(__shd_bulb_soft_shadows);
                gpu_set_blendmode(bm_add);
                _proj_matrix[@  8] = x;
                _proj_matrix[@  9] = y;
                _proj_matrix[@ 10] = light_penumbra_size;
                matrix_set(matrix_projection, _proj_matrix);
                vertex_submit(_static_vbuffer,  pr_trianglelist, -1);
                vertex_submit(_dynamic_vbuffer, pr_trianglelist, -1);
                
                //Draw light sprite
                shader_reset();
                matrix_set(matrix_projection, _vp_matrix);
                
                if (image_alpha < 1.0)
                {
                    //If this light is fading out, adjust the destination alpha channel
                    //TODO - Do this earlier during the wipe phase and before shadow casting
                    gpu_set_blendmode_ext(bm_src_alpha, bm_one);
                    draw_sprite_ext(sprite_index, image_index,
                                    x - _camera_l, y - _camera_t,
                                    image_xscale, image_yscale, image_angle,
                                    image_blend, 1.0 - image_alpha);
                }
                
                gpu_set_colorwriteenable(true, true, true, false);
                gpu_set_blendmode_ext(bm_inv_dest_alpha, bm_one);
                
                draw_sprite_ext(sprite_index, image_index,
                                x - _camera_l, y - _camera_t,
                                image_xscale, image_yscale, image_angle,
                                image_blend, image_alpha);
            }
        }
    }
    
    accumulate_nondeferred_hard_lights = function(_camera_l, _camera_t, _camera_r, _camera_b, _camera_cx, _camera_cy, _camera_w, _camera_h, _vp_matrix)
    {
        var _wipe_vbuffer    = wipe_vbuffer;
        var _static_vbuffer  = static_vbuffer;
        var _dynamic_vbuffer = dynamic_vbuffer;
        var _partial_clear   = partial_clear;
        
        //Calculate some transform coefficients
        var _inv_camera_w = 2/_camera_w;
        var _inv_camera_h = 2/_camera_h;
        if (BULB_FLIP_CAMERA_Y) _inv_camera_h = -_inv_camera_h;
        
        var _transformed_cam_x = _camera_cx*_inv_camera_w;
        var _transformed_cam_y = _camera_cy*_inv_camera_h;
        
        //Pre-build a custom projection matrix
        //[8] [9] are set per light
        var _proj_matrix = [      _inv_camera_w,                   0, 0,  0,
                                              0,       _inv_camera_h, 0,  0,
                                      undefined,           undefined, 0, -1,
                            -_transformed_cam_x, -_transformed_cam_y, 0,  1];
        
        // xOut = (x - z*(camX - lightX) - camX) / camW
        // yOut = (y - z*(camY - lightY) - camY) / camH
        // zOut = 0
        
        gpu_set_ztestenable(true);
        gpu_set_zwriteenable(true);
        
        if (mode == BULB_MODE.HARD_BM_MAX)
        {
            gpu_set_blendmode(bm_max);
            var _reset_shader = __shd_bulb_premultiply_alpha;
        }
        else
        {
            gpu_set_blendmode(bm_add);
            var _reset_shader = __shd_bulb_pass_through;
        }
        
        with (obj_par_light)
        {
            if (light_deferred && BULB_ALLOW_DEFERRED) continue;
            
            light_on_screen = visible && __bulb_rect_in_rect(x - light_w_half, y - light_h_half,
                                                             x + light_w_half, y + light_h_half,
                                                             _camera_l, _camera_t, _camera_r, _camera_b);
            
            //If this light is active, do some drawing
            if (light_on_screen)
            {
                //Draw shadow stencil
                gpu_set_zfunc(cmpfunc_always);
                gpu_set_colorwriteenable(false, false, false, false);
                
                //Reset zbuffer
                if (_partial_clear)
                {
                    draw_sprite_ext(sprite_index, image_index,
                                    x - _camera_l, y - _camera_t,
                                    image_xscale, image_yscale, image_angle,
                                    c_black, 1);
                    shader_set(__shd_bulb_hard_shadows);
                }
                else
                {
                    shader_set(__shd_bulb_hard_shadows);
                    vertex_submit(_wipe_vbuffer, pr_trianglelist, -1);
                }
                 
                //Render shadows
                _proj_matrix[@ 8] = _transformed_cam_x - x*_inv_camera_w;
                _proj_matrix[@ 9] = _transformed_cam_y - y*_inv_camera_h;
                matrix_set(matrix_projection, _proj_matrix);
                vertex_submit(_static_vbuffer,  pr_trianglelist, -1);
                vertex_submit(_dynamic_vbuffer, pr_trianglelist, -1);
                
                //Draw light sprite
                shader_set(_reset_shader);
                gpu_set_zfunc(cmpfunc_lessequal);
                gpu_set_colorwriteenable(true, true, true, false);
                matrix_set(matrix_projection, _vp_matrix);
                
                draw_sprite_ext(sprite_index, image_index,
                                x - _camera_l, y - _camera_t,
                                image_xscale, image_yscale, image_angle,
                                image_blend, image_alpha);
            }
        }
        
        gpu_set_ztestenable(false);
        gpu_set_zwriteenable(false);
    }
    
    update_deferred_lights = function(_camera_l, _camera_t, _camera_r, _camera_b)
    {
        var _static_vbuffer  = static_vbuffer;
        var _dynamic_vbuffer = dynamic_vbuffer;
        var _force_deferred  = force_deferred;
        
        ///////////Render out lights and shadows for each deferred light in the viewport
        var _sign = BULB_FLIP_CAMERA_Y? 1 : -1;
        
        //If culling is switched on, shadows will only be cast from the rear faces of occluders
        //This requires careful object placement as not to create weird graphical glitches
        gpu_set_cullmode(self_lighting? cull_counterclockwise : cull_noculling);
        
        with(obj_par_light)
        {
            if (!light_deferred && !_force_deferred) continue;
            
            light_on_screen = visible && __bulb_rect_in_rect(x - light_w_half, y - light_h_half,
                                                             x + light_w_half, y + light_h_half,
                                                             _camera_l, _camera_t,
                                                             _camera_r, _camera_b);
            
            //If this light is ready to be drawn...
            if (light_on_screen)
            {
                surface_set_target(light_surface);
                    
                //Draw the light sprite
                draw_sprite_ext(sprite_index, image_index,    light_w_half, light_h_half,    1, 1, 0,    merge_colour(c_black, image_blend, image_alpha), 1);
                    
                //Magical projection!
                shader_set(__shd_bulb_snap_vertex);
                    
                //var _view_matrix = matrix_build_lookat(_camera_w/2, _camera_h/2, -16000,   _camera_w/2, _camera_h/2, 0,   0, 1, 0);
                //var _view_matrix = [            1,            0,     0, 0,                   // [            1,            0,         0, 0, 
                //                                0,            1,     0, 0,                   //              0,            1,         0, 0, 
                //                                0,            0,     1, 0,                   //              0,            0,         1, 0, 
                //                     -_camera_w/2, -_camera_h/2, 16000, 1 ];                 //   -_camera_w/2, -_camera_h/2, -camera_z, 1 ]
                    
                //var _proj_matrix =  matrix_build_projection_ortho(_camera_w, -_camera_h, 1, 32000);
                //var _proj_matrix = [ 2/_camera_w,           0,           0,  0,             // [ 2/_camera_w,           0,                      0, 0,
                //                               0, 2/_camera_h,           0,  0,             //             0, 2/_camera_h,                      0, 0,
                //                               0,           0,  1/(32000-1), 0,             //             0,           0,       1/(z_far-z_near), 0,
                //                               0,           0, -1/(32000-1), 1 ];           //             0,           0, -z_near/(z_far-z_near), 1 ]
                    
                //var _vp_matrix = matrix_multiply(_new_view, _new_proj);
                //var _vp_matrix = [ 2/_camera_w,           0,           0, 0,                  // [ 2/_camera_w,            0,                                   0, 0,
                //                             0, 2/_camera_h,           0, 0,                  //             0, -2/_camera_h,                                   0, 0,
                //                             0,           0,     1/31999, 0,                  //             0,            0,                    1/(z_far-z_near), 0,
                //                            -1,           1, 15999/31999, 1 ];                //            -1,            1, (-camera_z - z_near)/(z_far-z_near), 1 ]
                    
                matrix_set(matrix_view, matrix_build_lookat(x, y, light_w,   x, y, 0,   dsin(-image_angle), -dcos(-image_angle), 0));
                matrix_set(matrix_projection, matrix_build_projection_perspective(image_xscale, image_yscale*_sign, 1, 32000));
                    
                //Tell the GPU to render the shadow geometry
                vertex_submit(_static_vbuffer,  pr_trianglelist, -1);
                vertex_submit(_dynamic_vbuffer, pr_trianglelist, -1);
                shader_reset();
                    
                surface_reset_target();
            }
        }
            
        gpu_set_cullmode(cull_noculling);
        shader_reset();
    }
    
    accumulate_deferred_lights = function()
    {
        var _force_deferred = force_deferred;
        
        //Use a cumulative blend mode to add lights together
        if (_force_deferred)
        {
            switch(mode)
            {
                case BULB_MODE.HARD_BM_ADD: gpu_set_blendmode(bm_add); break
                case BULB_MODE.HARD_BM_MAX: gpu_set_blendmode(bm_max); break;
                case BULB_MODE.SOFT_BM_ADD: gpu_set_blendmode(bm_add); break;
            }
        }
        
        with (obj_par_light)
        {
            if ((light_deferred || _force_deferred) && light_on_screen)
            {
                var _sin = -dsin(image_angle);
                var _cos =  dcos(image_angle);
                var _x = image_xscale*light_w_half*_cos - image_yscale*light_h_half*_sin;
                var _y = image_xscale*light_w_half*_sin + image_yscale*light_h_half*_cos;
                
                draw_surface_ext(light_surface, floor(x - _x - _camera_l + 0.5), floor(y - _y - _camera_t + 0.5), image_xscale, image_yscale, image_angle, c_white, 1);
            }
        }
    }
}



#region Internal Macros

#macro ON_DIRECTX ((os_type == os_windows) || (os_type == os_xboxone) || (os_type == os_uwp) || (os_type == os_winphone) || (os_type == os_win8native))

//Create a couple vertex formats
vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_colour();
global.__bulb_format_3d_colour = vertex_format_end();

//Create a standard vertex format
vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_texcoord();
global.__bulb_format_3d_texture = vertex_format_end();

#endregion



#region Internal Helper Functions

function __bulb_add_occlusion_hard(_vbuff)
{
    if (!BULB_CACHE_DYNAMIC_OCCLUDERS)
    {
        //Set up basic transforms to turn relative coordinates in arr_shadowGeometry[] into world-space coordinates
        var _sin = dsin(image_angle);
        var _cos = dcos(image_angle);
        
        var _x_sin = image_xscale*_sin;
        var _x_cos = image_xscale*_cos;
        var _y_sin = image_yscale*_sin;
        var _y_cos = image_yscale*_cos;
        
        //Loop through every line segment, remembering that we're storing coordinate data sequentially: { Ax1, Ay1, Bx1, Bx1,   Ax2, Ay2, Bx2, Bx2, ... }
        var _i = 0;
        repeat(shadow_geometry_count)
        {
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
            
            //Add to the vertex buffer
            vertex_position_3d(_vbuff,   _new_ax, _new_ay,  0);         vertex_colour(_vbuff,   c_black, 1);
            vertex_position_3d(_vbuff,   _new_bx, _new_by,  BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
            vertex_position_3d(_vbuff,   _new_bx, _new_by,  0);         vertex_colour(_vbuff,   c_black, 1);
            
            vertex_position_3d(_vbuff,   _new_ax, _new_ay,  0);         vertex_colour(_vbuff,   c_black, 1);
            vertex_position_3d(_vbuff,   _new_ax, _new_ay,  BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
            vertex_position_3d(_vbuff,   _new_bx, _new_by,  BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
        }
    }
    else
    {
        if ((last_image_angle != image_angle) or (last_image_x_scale != image_xscale) or (last_image_y_scale!= image_yscale))
        {
            last_image_angle   = image_angle;
            last_image_x_scale = image_xscale;
            last_image_y_scale = image_yscale;
            
            var _sin = dsin(image_angle);
            var _cos = dcos(image_angle);
            
            last_x_sin = image_xscale*_sin;
            last_x_cos = image_xscale*_cos;
            last_y_sin = image_yscale*_sin;
            last_y_cos = image_yscale*_cos;
            
            light_vertex_cache_dirty = true;
        }
        
        var _x_sin = last_x_sin;
        var _x_cos = last_x_cos;
        var _y_sin = last_y_sin;
        var _y_cos = last_y_cos;
        
        if ((light_obstacle_old_x != x) or (light_obstacle_old_y != y))
        {
            light_obstacle_old_x = x;
            light_obstacle_old_y = y;
            light_vertex_cache_dirty = true;
        
        }
        
        //Loop through every line segment, remembering that we're storing coordinate data sequentially: { Ax1, Ay1, Bx1, Bx1,   Ax2, Ay2, Bx2, Bx2, ... }
        var _i = 0;
        if (light_vertex_cache_dirty)
        {
            light_vertex_cache_dirty = false;
            
            repeat(shadow_geometry_count)
            {
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
                vertex_position_3d(_vbuff,   _new_ax, _new_ay, 0);         vertex_colour(_vbuff,   c_black, 1);
                vertex_position_3d(_vbuff,   _new_bx, _new_by, BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
                vertex_position_3d(_vbuff,   _new_bx, _new_by, 0);         vertex_colour(_vbuff,   c_black, 1);
                
                vertex_position_3d(_vbuff,   _new_ax, _new_ay, 0);         vertex_colour(_vbuff,   c_black, 1);
                vertex_position_3d(_vbuff,   _new_ax, _new_ay, BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
                vertex_position_3d(_vbuff,   _new_bx, _new_by, BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
            }
        }
        else
        {
            repeat(shadow_geometry_count)
            {
                //Build from cache
                var _new_ax = light_vertex_cache[_i++];
                var _new_ay = light_vertex_cache[_i++];
                var _new_bx = light_vertex_cache[_i++];
                var _new_by = light_vertex_cache[_i++];
                
                //Using textures (rather than untextureed) saves on shader_set() overhead... likely a trade-off depending on the GPU
                vertex_position_3d(_vbuff,   _new_ax, _new_ay, 0);         vertex_colour(_vbuff,   c_black, 1);
                vertex_position_3d(_vbuff,   _new_bx, _new_by, BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
                vertex_position_3d(_vbuff,   _new_bx, _new_by, 0);         vertex_colour(_vbuff,   c_black, 1);
                
                vertex_position_3d(_vbuff,   _new_ax, _new_ay, 0);         vertex_colour(_vbuff,   c_black, 1);
                vertex_position_3d(_vbuff,   _new_ax, _new_ay, BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
                vertex_position_3d(_vbuff,   _new_bx, _new_by, BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1); 
            }
        }
    }
}

function __bulb_add_occlusion_soft(_vbuff)
{
    if (!BULB_CACHE_DYNAMIC_OCCLUDERS)
    {
        //Set up basic transforms to turn relative coordinates in arr_shadowGeometry[] into world-space coordinates
        var _sin = dsin(image_angle);
        var _cos = dcos(image_angle);
        
        var _x_sin = image_xscale*_sin;
        var _x_cos = image_xscale*_cos;
        var _y_sin = image_yscale*_sin;
        var _y_cos = image_yscale*_cos;
        
        //Loop through every line segment, remembering that we're storing coordinate data sequentially: { Ax1, Ay1, Bx1, Bx1,   Ax2, Ay2, Bx2, Bx2, ... }
        var _i = 0;
        repeat(shadow_geometry_count)
        {
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
            
            //Add to the vertex buffer
            vertex_position_3d(_vbuff,   _new_ax, _new_ay,  0);         vertex_texcoord(_vbuff,  1, 1);
            vertex_position_3d(_vbuff,   _new_bx, _new_by,  BULB_ZFAR); vertex_texcoord(_vbuff,  1, 1);
            vertex_position_3d(_vbuff,   _new_bx, _new_by,  0);         vertex_texcoord(_vbuff,  1, 1);
            
            vertex_position_3d(_vbuff,   _new_ax, _new_ay,  0);         vertex_texcoord(_vbuff,  1, 1);
            vertex_position_3d(_vbuff,   _new_ax, _new_ay,  BULB_ZFAR); vertex_texcoord(_vbuff,  1, 1);
            vertex_position_3d(_vbuff,   _new_bx, _new_by,  BULB_ZFAR); vertex_texcoord(_vbuff,  1, 1);
            
            //Add data for the soft shadows
            vertex_position_3d(_vbuff,   _new_ax, _new_ay,  BULB_ZFAR); vertex_texcoord(_vbuff,  1, 0);
            vertex_position_3d(_vbuff,   _new_ax, _new_ay,  0);         vertex_texcoord(_vbuff,  0, 1);
            vertex_position_3d(_vbuff,   _new_ax, _new_ay,  BULB_ZFAR); vertex_texcoord(_vbuff,  0, 0);
            
            vertex_position_3d(_vbuff,   _new_ax, _new_ay, -BULB_ZFAR); vertex_texcoord(_vbuff,  0, 0); //Bit of a hack. We interpret this in __shd_bulb_soft_shadows
            vertex_position_3d(_vbuff,   _new_ax, _new_ay,  0);         vertex_texcoord(_vbuff,  0, 1);
            vertex_position_3d(_vbuff,   _new_ax, _new_ay,  BULB_ZFAR); vertex_texcoord(_vbuff,  1, 0);
        }
    }
    else
    {
        if ((last_image_angle != image_angle) or (last_image_x_scale != image_xscale) or (last_image_y_scale!= image_yscale))
        {
            last_image_angle   = image_angle;
            last_image_x_scale = image_xscale;
            last_image_y_scale = image_yscale;
            
            var _sin = dsin(image_angle);
            var _cos = dcos(image_angle);
            
            last_x_sin = image_xscale*_sin;
            last_x_cos = image_xscale*_cos;
            last_y_sin = image_yscale*_sin;
            last_y_cos = image_yscale*_cos;
            
            light_vertex_cache_dirty = true;
        }
        
        var _x_sin = last_x_sin;
        var _x_cos = last_x_cos;
        var _y_sin = last_y_sin;
        var _y_cos = last_y_cos;
        
        if ((light_obstacle_old_x != x) or (light_obstacle_old_y != y))
        {
        
            light_obstacle_old_x = x;
            light_obstacle_old_y = y;
            light_vertex_cache_dirty = true;
        
        }
        
        //Loop through every line segment, remembering that we're storing coordinate data sequentially: { Ax1, Ay1, Bx1, Bx1,   Ax2, Ay2, Bx2, Bx2, ... }
        var _i = 0;
        if (light_vertex_cache_dirty)
        {
            light_vertex_cache_dirty = false;
            
            repeat(shadow_geometry_count)
            {
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
                vertex_position_3d(_vbuff,   _new_ax, _new_ay, 0);         vertex_colour(_vbuff,   c_black, 1);
                vertex_position_3d(_vbuff,   _new_bx, _new_by, BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
                vertex_position_3d(_vbuff,   _new_bx, _new_by, 0);         vertex_colour(_vbuff,   c_black, 1);
                
                vertex_position_3d(_vbuff,   _new_ax, _new_ay, 0);         vertex_colour(_vbuff,   c_black, 1);
                vertex_position_3d(_vbuff,   _new_ax, _new_ay, BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
                vertex_position_3d(_vbuff,   _new_bx, _new_by, BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
            }
        }
        else
        {
            repeat(shadow_geometry_count)
            {
                //Build from cache
                var _new_ax = light_vertex_cache[_i++];
                var _new_ay = light_vertex_cache[_i++];
                var _new_bx = light_vertex_cache[_i++];
                var _new_by = light_vertex_cache[_i++];
                
                //Using textures (rather than untextureed) saves on shader_set() overhead... likely a trade-off depending on the GPU
                vertex_position_3d(_vbuff,   _new_ax, _new_ay, 0);         vertex_colour(_vbuff,   c_black, 1);
                vertex_position_3d(_vbuff,   _new_bx, _new_by, BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
                vertex_position_3d(_vbuff,   _new_bx, _new_by, 0);         vertex_colour(_vbuff,   c_black, 1);
                
                vertex_position_3d(_vbuff,   _new_ax, _new_ay, 0);         vertex_colour(_vbuff,   c_black, 1);
                vertex_position_3d(_vbuff,   _new_ax, _new_ay, BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
                vertex_position_3d(_vbuff,   _new_bx, _new_by, BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1); 
            }
        }
    }
}

function __bulb_rect_in_rect(_ax1, _ay1, _ax2, _ay2, _bx1, _by1, _bx2, _by2)
{
    return !((_bx1 > _ax2) || (_bx2 < _ax1) || (_by1 > _ay2) || (_by2 < _ay1));
}

#endregion