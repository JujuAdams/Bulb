/// @param ambientColour
/// @param mode
/// @param smooth

enum BULB_MODE
{
    HARD_BM_ADD,
    HARD_BM_ADD_SELFLIGHTING,
    HARD_BM_MAX,
    HARD_BM_MAX_SELFLIGHTING,
    SOFT_BM_ADD,
    __SIZE
}

function bulb_create_renderer(_ambient_colour, _mode, _smooth)
{
    with(new __bulb_class_renderer())
    {
        ambient_colour = _ambient_colour;
        mode           = _mode;
        smooth         = _smooth;
        return self;
    }
}

function __bulb_class_renderer() constructor
{
    //Assign the ambient colour used for the darkest areas of the screen. This can be changed on the fly
    ambient_colour = c_black;
    
    //If culling is switched on, shadows will only be cast from the rear faces of occluders
    //This requires careful object placement as not to create weird graphical glitches
    self_lighting = false;
    
    //The smoothing mode controls texture filtering both when accumulating lights and when drawing the resulting surface
    smooth = false;
    
    mode = BULB_MODE.HARD_BM_ADD;
    freed = false;
    
    //Initialise variables used and updated in bulb_build()
    static_vbuffer  = undefined; //Vertex buffer describing the geometry of static occluder objects
    dynamic_vbuffer = undefined; //As above but for dynamic shadow occluders. This is updated every step
    wipe_vbuffer    = undefined; //This vertex buffer is used to reset the z-buffer during accumulation of non-deferred lights
    surface         = undefined; //Screen-space surface for final accumulation of lights
    
    surface_width  = undefined;
    surface_height = undefined;
    
    static_occluders_array  = [];
    dynamic_occluders_array = [];
    lights_array            = [];
    
    
    #region Public Methods
    
    static update_from_camera = function(_camera)
    {
        return update(camera_get_view_x(_camera), camera_get_view_y(_camera), camera_get_view_width(_camera), camera_get_view_height(_camera));
    }
    
    static update = function(_camera_l, _camera_t, _camera_w, _camera_h)
    {
        if (freed) return undefined;
        
        if (surface_width  == undefined) surface_width  = _camera_w;
        if (surface_height == undefined) surface_height = _camera_h;
        
        var _camera_r  = _camera_l + _camera_w;
        var _camera_b  = _camera_t + _camera_h;
        var _camera_cx = _camera_l + 0.5*_camera_w;
        var _camera_cy = _camera_t + 0.5*_camera_h;
        
        //Construct our wipe/static/dynamic vertex buffers
        __update_vertex_buffers(_camera_l, _camera_t, _camera_r, _camera_b, _camera_w, _camera_h);
        
        //Create accumulating lighting surface
        surface_set_target(get_surface());
        
        //Record the current texture filter state, then set our new filter state
        var _old_tex_filter = gpu_get_tex_filter();
        gpu_set_tex_filter(smooth);
    
        //Clear the surface with the ambient colour
        draw_clear(ambient_colour);
        
        //If we're not forcing deferred rendering everywhere, update those lights
        accumulate_lights(_camera_l, _camera_t, _camera_r, _camera_b, _camera_cx, _camera_cy, _camera_w, _camera_h);
        
        //Restore the old filter state
        gpu_set_tex_filter(_old_tex_filter);
        
        surface_reset_target();
    }
    
    /// @param x
    /// @param y
    /// @param [width]
    /// @param [height]
    static draw = function()
    {
        if (freed) return undefined;
        
        var _x      = argument[0];
        var _y      = argument[1];
        var _width  = ((argument_count > 2) && (argument[2] != undefined))? argument[2] : surface_width;
        var _height = ((argument_count > 3) && (argument[3] != undefined))? argument[3] : surface_height;
        
        if ((surface != undefined) && surface_exists(surface))
        {
            //Record the current texture filter state, then set our new filter state
            var _old_tex_filter = gpu_get_tex_filter();
            gpu_set_tex_filter(smooth);
            
            gpu_set_blendmode_ext(bm_dest_color, bm_zero);
            gpu_set_colorwriteenable(true, true, true, false);
            
            draw_surface_stretched(surface, _x, _y, _width, _height);
            
            gpu_set_blendmode(bm_normal);
            gpu_set_colorwriteenable(true, true, true, true);
            
            //Restore the old filter state
            gpu_set_tex_filter(_old_tex_filter);
        }
    }
    
    static get_surface = function()
    {
        if (freed) return undefined;
        if ((surface_width == undefined) || (surface_height == undefined)) return undefined;
        
        if ((surface != undefined) && ((surface_get_width(surface) != surface_width) || (surface_get_height(surface) != surface_height)))
        {
            surface_free(surface);
            surface = undefined;
        }
        
        if ((surface == undefined) || !surface_exists(surface))
        {
            surface = surface_create(surface_width, surface_height);
            
            surface_set_target(surface);
            draw_clear_alpha(c_black, 1.0);
            surface_reset_target();
        }
        
        return surface;
    }
    
    static clear_static_occluders = function()
    {
        if (freed) return undefined;
        
        array_resize(static_occluders, 0);
    }
    
    static free = function()
    {
        __free_vertex_buffers();
        __free_surface();
        
        freed = true;
    }
    
    #endregion
    
    #region Update vertex buffers
    
    static __update_vertex_buffers = function(_camera_l, _camera_t, _camera_r, _camera_b, _camera_w, _camera_h)
    {
        if (freed) return undefined;
        
        ///////////Discover camera variables
        var _camera_exp_l = _camera_l - BULB_DYNAMIC_OCCLUDER_RANGE;
        var _camera_exp_t = _camera_t - BULB_DYNAMIC_OCCLUDER_RANGE;
        var _camera_exp_r = _camera_r + BULB_DYNAMIC_OCCLUDER_RANGE;
        var _camera_exp_b = _camera_b + BULB_DYNAMIC_OCCLUDER_RANGE;
        
        //One-time construction of a triangle to wipe the z-buffer
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
        
        //One-time construction of the static occluder geometry
        if (static_vbuffer == undefined)
        {
            //Create a new vertex buffer
            static_vbuffer = vertex_create_buffer();
            var _static_vbuffer = static_vbuffer;
            
            //Add static shadow caster vertices to the relevant vertex buffer
            if (mode == BULB_MODE.SOFT_BM_ADD)
            {
                vertex_begin(static_vbuffer, global.__bulb_format_3d_texture);
                with (BULB_STATIC_OCCLUDER_PARENT) __bulb_add_occlusion_soft(_static_vbuffer);
            }
            else
            {
                vertex_begin(static_vbuffer, global.__bulb_format_3d_colour);
                with (BULB_STATIC_OCCLUDER_PARENT) __bulb_add_occlusion_hard(_static_vbuffer);
            }
            
            vertex_end(static_vbuffer);
            
            //Freeze this buffer for speed boosts later on (though only if we have vertices in this buffer)
            if (vertex_get_number(static_vbuffer) > 0) vertex_freeze(static_vbuffer);
        }
        
        //Refresh the dynamic occluder geometry
        if (dynamic_vbuffer == undefined) dynamic_vbuffer = vertex_create_buffer();
        var _dynamic_vbuffer = dynamic_vbuffer;
        
        //Add dynamic occluder vertices to the relevant vertex buffer
        if (mode == BULB_MODE.SOFT_BM_ADD)
        {
            vertex_begin(_dynamic_vbuffer, global.__bulb_format_3d_texture);
            with (BULB_DYNAMIC_OCCLUDER_PARENT)
            {
                __bulb_on_screen = visible && __bulb_rect_in_rect(bbox_left, bbox_top,
                                                                  bbox_right, bbox_bottom,
                                                                  _camera_exp_l, _camera_exp_t,
                                                                  _camera_exp_r, _camera_exp_b);
                if (__bulb_on_screen) __bulb_add_occlusion_soft(_dynamic_vbuffer);
            }
        }
        else
        {
            vertex_begin(_dynamic_vbuffer, global.__bulb_format_3d_colour);
            with (BULB_DYNAMIC_OCCLUDER_PARENT)
            {
                __bulb_on_screen = visible && __bulb_rect_in_rect(bbox_left, bbox_top,
                                                                  bbox_right, bbox_bottom,
                                                                  _camera_exp_l, _camera_exp_t,
                                                                  _camera_exp_r, _camera_exp_b);
                if (__bulb_on_screen) __bulb_add_occlusion_hard(_dynamic_vbuffer);
            }
        }
        
        vertex_end(_dynamic_vbuffer);
    }
    
    #endregion
    
    #region Accumulate lights
    
    static accumulate_lights = function(_camera_l, _camera_t, _camera_r, _camera_b, _camera_cx, _camera_cy, _camera_w, _camera_h)
    {
        if (freed) return undefined;
        
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
        if (__BULB_FLIP_CAMERA_Y)
        {
            //DirectX platforms want the Y-axis flipped
            var _vp_matrix = [2/_camera_w,            0, 0, 0,
                                        0, -2/_camera_h, 0, 0,
                                        0,            0, 0, 0,
                                       -1,            1, 1, 1];
        }
        else
        {
            var _vp_matrix = [2/_camera_w,           0, 0, 0,
                                        0, 2/_camera_h, 0, 0,
                                        0,           0, 0, 0,
                                       -1,          -1, 1, 1];
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
            accumulate_soft_lights(_camera_l, _camera_t, _camera_r, _camera_b, _camera_cx, _camera_cy, _camera_w, _camera_h, _vp_matrix);
        }
        else
        {
            accumulate_hard_lights(_camera_l, _camera_t, _camera_r, _camera_b, _camera_cx, _camera_cy, _camera_w, _camera_h, _vp_matrix);
        }
            
        //Reset GPU properties
        shader_reset();
        gpu_set_colorwriteenable(true, true, true, true);
        gpu_set_cullmode(cull_noculling);
    }
    
    #endregion
    
    #region Accumulate soft lights
    
    static accumulate_soft_lights = function(_camera_l, _camera_t, _camera_r, _camera_b, _camera_cx, _camera_cy, _camera_w, _camera_h, _vp_matrix)
    {
        if (freed) return undefined;
        
        var _wipe_vbuffer    = wipe_vbuffer;
        var _static_vbuffer  = static_vbuffer;
        var _dynamic_vbuffer = dynamic_vbuffer;
        
        //Calculate some transform coefficients
        var _inv_camera_w = 2/_camera_w;
        var _inv_camera_h = 2/_camera_h;
        if (__BULB_FLIP_CAMERA_Y) _inv_camera_h = -_inv_camera_h;
        
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
        
        var _i = 0;
        repeat(array_length(lights_array))
        {
            var _weak = lights_array[_i];
            if (!weak_ref_alive(_weak))
            {
                array_delete(lights_array, 1, 1);
            }
            else
            {
                with(_weak.ref)
                {
                    __on_screen = visible && __bulb_rect_in_rect(x - __width_half, y - __height_half,
                                                                 x + __width_half, y + __height_half,
                                                                 _camera_l, _camera_t, _camera_r, _camera_b);
                    
                    //If this light is active, do some drawing
                    if (__on_screen)
                    {
                        if (cast_shadows)
                        {
                            gpu_set_colorwriteenable(false, false, false, true);
                            
                            //Clear alpha channel
                            gpu_set_blendmode(bm_subtract);
                            
                            if (__BULB_PARTIAL_CLEAR)
                            {
                                draw_sprite_ext(sprite, image,
                                                x - _camera_l, y - _camera_t,
                                                xscale, yscale, angle,
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
                            _proj_matrix[@ 10] = penumbra_size;
                            matrix_set(matrix_projection, _proj_matrix);
                            vertex_submit(_static_vbuffer,  pr_trianglelist, -1);
                            vertex_submit(_dynamic_vbuffer, pr_trianglelist, -1);
                            
                            //Draw light sprite
                            shader_reset();
                            matrix_set(matrix_projection, _vp_matrix);
                            
                            if (alpha < 1.0)
                            {
                                //If this light is fading out, adjust the destination alpha channel
                                //TODO - Do this earlier during the wipe phase and before shadow casting
                                gpu_set_blendmode_ext(bm_src_alpha, bm_one);
                                draw_sprite_ext(sprite, image,
                                                x - _camera_l, y - _camera_t,
                                                xscale, yscale, angle,
                                                blend, 1.0 - alpha);
                            }
                            
                            gpu_set_colorwriteenable(true, true, true, false);
                            gpu_set_blendmode_ext(bm_inv_dest_alpha, bm_one);
                            
                            draw_sprite_ext(sprite, image,
                                            x - _camera_l, y - _camera_t,
                                            xscale, yscale, angle,
                                            blend, alpha);
                        }
                        else
                        {
                            gpu_set_blendmode(bm_add);
                            draw_sprite_ext(sprite, image,
                                            x - _camera_l, y - _camera_t,
                                            xscale, yscale, angle,
                                            blend, alpha);
                        }
                    }
                }
                
                ++_i;
            }
        }
    }
    
    #endregion
    
    #region Accumulate hard lights
    
    static accumulate_hard_lights = function(_camera_l, _camera_t, _camera_r, _camera_b, _camera_cx, _camera_cy, _camera_w, _camera_h, _vp_matrix)
    {
        if (freed) return undefined;
        
        var _wipe_vbuffer    = wipe_vbuffer;
        var _static_vbuffer  = static_vbuffer;
        var _dynamic_vbuffer = dynamic_vbuffer;
        
        //Calculate some transform coefficients
        var _inv_camera_w = 2/_camera_w;
        var _inv_camera_h = 2/_camera_h;
        if (__BULB_FLIP_CAMERA_Y) _inv_camera_h = -_inv_camera_h;
        
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
        
        shader_set(_reset_shader);
        matrix_set(matrix_projection, _vp_matrix);
        
        with (BULB_LIGHT_PARENT)
        {
            __bulb_on_screen = visible && __bulb_rect_in_rect(x - __bulb_light_width_half, y - __bulb_light_height_half,
                                                              x + __bulb_light_width_half, y + __bulb_light_height_half,
                                                              _camera_l, _camera_t, _camera_r, _camera_b);
            
            //If this light is active, do some drawing
            if (__bulb_on_screen)
            {
                if (__bulb_cast_shadows)
                {
                    //Draw shadow stencil
                    gpu_set_zfunc(cmpfunc_always);
                    gpu_set_colorwriteenable(false, false, false, false);
                    
                    //Reset zbuffer
                    if (__BULB_PARTIAL_CLEAR)
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
                else
                {
                    gpu_set_zfunc(cmpfunc_always);
                    draw_sprite_ext(sprite_index, image_index,
                                    x - _camera_l, y - _camera_t,
                                    image_xscale, image_yscale, image_angle,
                                    image_blend, image_alpha);
                }
            }
        }
        
        gpu_set_ztestenable(false);
        gpu_set_zwriteenable(false);
    }
    
    static __free_vertex_buffers = function()
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
    
    static __free_surface = function()
    {
        if ((surface != undefined) && surface_exists(surface))
        {
            surface_free(surface);
            surface = undefined;
        }
    }
    
    #endregion
}



#region Internal Macros + Helper Functions

#macro __BULB_VERSION        "20.0.0"
#macro __BULB_DATE           "2021-02-12"
#macro __BULB_ON_DIRECTX     ((os_type == os_windows) || (os_type == os_xboxone) || (os_type == os_uwp) || (os_type == os_winphone) || (os_type == os_win8native))
#macro __BULB_ZFAR           16000
#macro __BULB_FLIP_CAMERA_Y  __BULB_ON_DIRECTX
#macro __BULB_PARTIAL_CLEAR  true

__bulb_trace("Welcome to Bulb by @jujuadams! This is version " + __BULB_VERSION + ", " + __BULB_DATE);

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

function __bulb_trace()
{
    var _string = "";
    
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    show_debug_message("Bulb: " + _string);
}

#endregion