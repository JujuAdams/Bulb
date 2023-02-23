/// @param ambientColour
/// @param mode
/// @param smooth
/// @param maxGroups

function BulbRendererWithGroups(_ambientColour, _mode, _smooth, _maxGroups) constructor
{
    //Assign the ambient colour used for the darkest areas of the screen. This can be changed on the fly
    ambientColor = _ambientColour;
    
    //The smoothing mode controls texture filtering both when accumulating lights and when drawing the resulting __surface
    smooth = _smooth;
    
    mode = _mode;
    
    surfaceWidth  = -1;
    surfaceHeight = -1;
    
    //The highest mask index that can be specified
    if ((_maxGroups <= 0) || (_maxGroups > 64)) __BulbError("Maximum mask index should be between 1 and 64 inclusive (got ", _maxGroups, ")");
    __maxGroups = _maxGroups;
    
    __groupArray = array_create(__maxGroups);
    var _i = 0;
    repeat(__maxGroups)
    {
        //Initialise variables used and updated in .__UpdateVertexBuffers()
        var _groupStruct = {
            staticVBuffer  : undefined, //Vertex buffer describing the geometry of static occluder objects
            dynamicVBuffer : undefined, //As above but for dynamic shadow occluders. This is updated every step
        }
        
        __groupArray[@ _i] = _groupStruct;
        
        ++_i;
    }
    
    __wipeVBuffer = undefined; //This vertex buffer is used to reset the z-buffer during accumulation of non-deferred lights
    __surface     = undefined; //Screen-space __surface for final accumulation of lights
    
    __staticOccludersArray  = [];
    __dynamicOccludersArray = [];
    __lightsArray           = [];
    __sunlightArray         = [];
    __shadowOverlayArray    = [];
    __lightOverlayArray     = [];
    
    __freed   = false;
    __oldMode = undefined;
    
    __clipEnabled      = false;
    __clipSurface      = undefined;
    __clipIsShadow     = true;
    __clipAlpha        = 1.0;
    __clipInvert       = false;
    __clipValueToAlpha = false;
    
    
    
    #region Public Methods
    
    static SetSurfaceDimensionsFromCamera = function(_camera)
    {
        var _projMatrix = camera_get_proj_mat(_camera);
        var _width  = round(abs(2/_projMatrix[0]));
        var _height = round(abs(2/_projMatrix[5]));
        
        return SetSurfaceDimensions(_width, _height);
    }
    
    static SetSurfaceDimensions = function(_width, _height)
    {
        surfaceWidth  = _width;
        surfaceHeight = _height;
        
        GetSurface();
        GetClippingSurface();
    }
    
    static SetClippingSurface = function(_clipIsShadow, _clipAlpha, _clipInvert = false, _hsvValueToAlpha = false)
    {
        __clipEnabled      = true;
        __clipIsShadow     = _clipIsShadow;
        __clipAlpha        = _clipAlpha;
        __clipInvert       = _clipInvert;
        __clipValueToAlpha = _hsvValueToAlpha;
    }
    
    static RemoveClippingSurface = function()
    {
        __clipEnabled = false;
        __FreeClipSurface();
    }
    
    static CopyClippingSurface = function(_surface)
    {
        gpu_set_blendmode_ext(bm_one, bm_zero);
        surface_copy(GetClippingSurface(), 0, 0, _surface);
        gpu_set_blendmode(bm_normal);
    }
    
    static SetAmbientColor = function(_color)
    {
        ambientColor = _color;
    }
    
    static GetAmbientColor = function()
    {
        return ambientColor;
    }
    
    static UpdateFromCamera = function(_camera)
    {
        //Deploy PROPER MATHS in case the dev is using matrices
        
        var _viewMatrix = camera_get_view_mat(_camera);
        var _projMatrix = camera_get_proj_mat(_camera);
        
        var _cameraX          = -_viewMatrix[12];
        var _cameraY          = -_viewMatrix[13];
        var _cameraViewWidth  = round(abs(2/_projMatrix[0]));
        var _cameraViewHeight = round(abs(2/_projMatrix[5]));
        var _cameraLeft       = _cameraX - _cameraViewWidth/2;
        var _cameraTop        = _cameraY - _cameraViewHeight/2;
        
        return Update(_cameraLeft, _cameraTop, _cameraViewWidth, _cameraViewHeight);
    }
    
    static Update = function(_cameraL, _cameraT, _cameraW, _cameraH)
    {
        if (__freed) return undefined;
        
        if (surfaceWidth  <= 0) surfaceWidth  = _cameraW;
        if (surfaceHeight <= 0) surfaceHeight = _cameraH;
        
        if (mode != __oldMode)
        {
            __oldMode = mode;
            __FreeVertexBuffers();
        }
        
        var _cameraR  = _cameraL + _cameraW;
        var _cameraB  = _cameraT + _cameraH;
        var _cameraCX = _cameraL + 0.5*_cameraW;
        var _cameraCY = _cameraT + 0.5*_cameraH;
        
        //Construct our wipe/static/dynamic vertex buffers
        __UpdateVertexBuffers(_cameraL, _cameraT, _cameraR, _cameraB, _cameraW, _cameraH);
        
        //Create accumulating lighting __surface
        surface_set_target(GetSurface());
        
        //Record the current texture filter state, then set our new filter state
        var _old_tex_filter = gpu_get_tex_filter();
        gpu_set_tex_filter(smooth);
    
        //Clear the __surface with the ambient colour
        draw_clear(ambientColor);
        
        //If we're not forcing deferred rendering everywhere, update those lights
        AccumulateLights(_cameraL, _cameraT, _cameraR, _cameraB, _cameraCX, _cameraCY, _cameraW, _cameraH);
        
        if (__clipEnabled) __ApplyClippingSurface();
        
        //Restore the old filter state
        gpu_set_tex_filter(_old_tex_filter);
        
        surface_reset_target();
    }
    
    /// @param camera
    /// @param [alpha]
    static DrawOnCamera = function()
    {
        var _camera = argument[0];
        var _alpha  = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : undefined;
        
        var _viewMatrix = camera_get_view_mat(_camera);
        var _projMatrix = camera_get_proj_mat(_camera);
        
        //Deploy PROPER MATHS in case the dev is using matrices
        var _cameraX          = -_viewMatrix[12];
        var _cameraY          = -_viewMatrix[13];
        var _cameraViewWidth  = round(abs(2/_projMatrix[0]));
        var _cameraViewHeight = round(abs(2/_projMatrix[5]));
        var _cameraLeft       = _cameraX - _cameraViewWidth/2;
        var _cameraTop        = _cameraY - _cameraViewHeight/2;
        
        return Draw(_cameraLeft, _cameraTop, _cameraViewWidth, _cameraViewHeight, _alpha);
    }
    
    /// @param x
    /// @param y
    /// @param [width]
    /// @param [height]
    /// @param [alpha]
    static Draw = function()
    {
        if (__freed) return undefined;
        
        var _x      = argument[0];
        var _y      = argument[1];
        var _width  = ((argument_count > 2) && (argument[2] != undefined))? argument[2] : surfaceWidth;
        var _height = ((argument_count > 3) && (argument[3] != undefined))? argument[3] : surfaceHeight;
        var _alpha  = ((argument_count > 4) && (argument[4] != undefined))? argument[4] : 1.0;
        
        if ((__surface != undefined) && surface_exists(__surface))
        {
            //Record the current texture filter state, then set our new filter state
            var _old_tex_filter = gpu_get_tex_filter();
            gpu_set_tex_filter(smooth);
            
            gpu_set_colorwriteenable(true, true, true, false);
            
            if (_alpha == 1.0)
            {
                //Don't use the shader if we don't have to!
                gpu_set_blendmode_ext(bm_dest_color, bm_zero);
                draw_surface_stretched(__surface, _x, _y, _width, _height);
            }
            else
            {
                gpu_set_blendmode_ext(bm_dest_color, bm_inv_src_alpha);
                shader_set(__shdBulbFinalRender);
                draw_surface_stretched_ext(__surface, _x, _y, _width, _height, c_white, _alpha);
                shader_reset();
            }
            
            gpu_set_blendmode(bm_normal);
            gpu_set_colorwriteenable(true, true, true, true);
            
            //Restore the old filter state
            gpu_set_tex_filter(_old_tex_filter);
        }
    }
    
    static GetSurface = function()
    {
        if (__freed) return undefined;
        if ((surfaceWidth <= 0) || (surfaceHeight <= 0)) return undefined;
        
        if ((__surface != undefined) && ((surface_get_width(__surface) != surfaceWidth) || (surface_get_height(__surface) != surfaceHeight)))
        {
            surface_free(__surface);
            __surface = undefined;
        }
        
        if ((__surface == undefined) || !surface_exists(__surface))
        {
            __surface = surface_create(surfaceWidth, surfaceHeight);
            
            surface_set_target(__surface);
            draw_clear_alpha(c_black, 1.0);
            surface_reset_target();
        }
        
        return __surface;
    }
    
    static GetClippingSurface = function()
    {
        if (__freed || !__clipEnabled) return undefined;
        if ((surfaceWidth <= 0) || (surfaceHeight <= 0)) return undefined;
        
        if ((__clipSurface != undefined) && ((surface_get_width(__clipSurface) != surfaceWidth) || (surface_get_height(__clipSurface) != surfaceHeight)))
        {
            surface_free(__clipSurface);
            __clipSurface = undefined;
        }
        
        if ((__clipSurface == undefined) || !surface_exists(__clipSurface))
        {
            __clipSurface = surface_create(surfaceWidth, surfaceHeight);
            
            surface_set_target(__clipSurface);
            
            if (__clipInvert)
            {
                draw_clear_alpha(c_black, 0.0);
            }
            else
            {
                draw_clear_alpha(c_white, 1.0);
            }
            
            surface_reset_target();
        }
        
        return __clipSurface;
    }
    
    static RefreshStaticOccluders = function()
    {
        if (__freed) return undefined;
        
        var _i = 0;
        repeat(__maxGroups)
        {
            with(__groupArray[_i])
            {
                if (staticVBuffer != undefined)
                {
                    vertex_delete_buffer(staticVBuffer);
                    staticVBuffer = undefined;
                }
            }
            
            ++_i;
        }
    }
    
    static Free = function()
    {
        __FreeVertexBuffers();
        __FreeSurface();
        __FreeClipSurface();
        
        __freed = true;
    }
    
    #endregion
    
    static __FreeVertexBuffers = function()
    {
        if (__wipeVBuffer != undefined)
        {
            vertex_delete_buffer(__wipeVBuffer);
            __wipeVBuffer = undefined;
        }
        
        if (__staticVBuffer != undefined)
        {
            vertex_delete_buffer(__staticVBuffer);
            __staticVBuffer = undefined;
        }
        
        if (__dynamicVBuffer != undefined)
        {
            vertex_delete_buffer(__dynamicVBuffer);
            __dynamicVBuffer = undefined;
        }
    }
    
    static __FreeSurface = function()
    {
        if ((__surface != undefined) && surface_exists(__surface))
        {
            surface_free(__surface);
            __surface = undefined;
        }
    }
    
    static __FreeClipSurface = function()
    {
        if ((__clipSurface != undefined) && surface_exists(__clipSurface))
        {
            surface_free(__clipSurface);
            __clipSurface = undefined;
        }
    }
    
    #region Update vertex buffers
    
    static __UpdateVertexBuffers = function(_cameraL, _cameraT, _cameraR, _cameraB, _cameraW, _cameraH)
    {
        if (__freed) return undefined;
        
        ///////////Discover camera variables
        var _cameraExpL = _cameraL - BULB_DYNAMIC_OCCLUDER_RANGE;
        var _cameraExpT = _cameraT - BULB_DYNAMIC_OCCLUDER_RANGE;
        var _cameraExpR = _cameraR + BULB_DYNAMIC_OCCLUDER_RANGE;
        var _cameraExpB = _cameraB + BULB_DYNAMIC_OCCLUDER_RANGE;
        
        //One-time construction of a triangle to wipe the z-buffer
        //Using textures (rather than untextured) saves on shader_set() overhead... likely a trade-off depending on the GPU
        if (__wipeVBuffer == undefined)
        {
            __wipeVBuffer = vertex_create_buffer();
            vertex_begin(__wipeVBuffer, global.__bulb_format_3d_colour);
            
            vertex_position_3d(__wipeVBuffer,          0,          0, 0); vertex_colour(__wipeVBuffer, c_black, 1);
            vertex_position_3d(__wipeVBuffer, 2*_cameraW,          0, 0); vertex_colour(__wipeVBuffer, c_black, 1);
            vertex_position_3d(__wipeVBuffer,          0, 2*_cameraH, 0); vertex_colour(__wipeVBuffer, c_black, 1);
            
            vertex_end(__wipeVBuffer);
            vertex_freeze(__wipeVBuffer);
        }
        
        var _groupArray   = __groupArray;
        var _staticArray  = __staticOccludersArray;
        var _staticCount  = array_length(_staticArray);
        var _dynamicArray = __dynamicOccludersArray;
        var _dynamicCount = array_length(_dynamicArray);
        
        //Pre-parse the static occluder array to remove any dead weak references
        var _i = 0;
        repeat(_staticCount)
        {
            var _weak = _staticArray[_i];
            if (!weak_ref_alive(_weak) || _weak.ref.__destroyed)
            {
                array_delete(_staticArray, _i, 1);
            }
            else
            {
                ++_i;
            }
        }
        
        //Pre-parse the dynamic occluder array to remove any dead weak references
        var _i = 0;
        repeat(_dynamicCount)
        {
            var _weak = _dynamicArray[_i];
            if (!weak_ref_alive(_weak) || _weak.ref.__destroyed)
            {
                array_delete(_dynamicArray, _i, 1);
            }
            else
            {
                ++_i;
            }
        }
        
        //Build our vertex buffers per group depending on our rendering mode
        if (mode == BULB_MODE.SOFT_BM_ADD)
        {
            var _j = 0;
            repeat(__maxGroups)
            {
                var _bit = 1 << _j;
                with(_groupArray[_j])
                {
                    //One-time construction of the static occluder geometry
                    if (staticVBuffer == undefined)
                    {
                        //Create a new vertex buffer
                        staticVBuffer = vertex_create_buffer();
                        var _staticVBuffer = staticVBuffer;
                        vertex_begin(_staticVBuffer, global.__bulb_format_3d_texture);
                        
                        //Iterate over the static occluders and add them to this group as necessary
                        var _i = 0;
                        repeat(_staticCount)
                        {
                            with(_staticArray[_i].ref)
                            {
                                if ((bitmask & _bit) > 0) __BulbAddOcclusionSoft(_staticVBuffer);
                            }
                            
                            ++_i;
                        }
                        
                        vertex_end(_staticVBuffer);
                        
                        //Freeze this buffer for speed boosts later on (though only if we have vertices in this buffer)
                        if (vertex_get_number(_staticVBuffer) > 0) vertex_freeze(_staticVBuffer);
                    }
                    
                    
                    
                    //Refresh the dynamic occluder geometry
                    if (dynamicVBuffer == undefined) dynamicVBuffer = vertex_create_buffer();
                    var _dynamicVBuffer = dynamicVBuffer;
                    vertex_begin(_dynamicVBuffer, global.__bulb_format_3d_texture);
                    
                    //Iterate over the dynamic occluders and add them to this group as necessary
                    var _i = 0;
                    repeat(_dynamicCount)
                    {
                        with(_dynamicArray[_i].ref)
                        {
                            if (((bitmask & _bit) > 0) && __IsOnScreen(_cameraExpL, _cameraExpT, _cameraExpR, _cameraExpB))
                            {
                                __BulbAddOcclusionSoft(_dynamicVBuffer);
                            }
                        }
                        
                        ++_i;
                    }
                    
                    vertex_end(_dynamicVBuffer);
                }
            
                ++_j;
            }
        }
        else
        {
            var _j = 0;
            repeat(__maxGroups)
            {
                var _bit = 1 << _j;
                with(_groupArray[_j])
                {
                    //One-time construction of the static occluder geometry
                    if (staticVBuffer == undefined)
                    {
                        //Create a new vertex buffer
                        staticVBuffer = vertex_create_buffer();
                        var _staticVBuffer = staticVBuffer;
                        vertex_begin(_staticVBuffer, global.__bulb_format_3d_colour);
                        
                        //Iterate over the static occluders and add them to this group as necessary
                        var _i = 0;
                        repeat(_staticCount)
                        {
                            with(_staticArray[_i].ref)
                            {
                                if ((bitmask & _bit) > 0) __BulbAddOcclusionHard(_staticVBuffer);
                            }
                            
                            ++_i;
                        }
                        
                        vertex_end(_staticVBuffer);
                        
                        //Freeze this buffer for speed boosts later on (though only if we have vertices in this buffer)
                        if (vertex_get_number(_staticVBuffer) > 0) vertex_freeze(_staticVBuffer);
                    }
                    
                    //Refresh the dynamic occluder geometry
                    if (dynamicVBuffer == undefined) dynamicVBuffer = vertex_create_buffer();
                    var _dynamicVBuffer = dynamicVBuffer;
                    vertex_begin(_dynamicVBuffer, global.__bulb_format_3d_colour);
                    
                    //Iterate over the dynamic occluders and add them to this group as necessary
                    var _i = 0;
                    repeat(_dynamicCount)
                    {
                        with(_dynamicArray[_i].ref)
                        {
                            if (((bitmask & _bit) > 0) && __IsOnScreen(_cameraExpL, _cameraExpT, _cameraExpR, _cameraExpB))
                            {
                                __BulbAddOcclusionHard(_dynamicVBuffer);
                            }
                        }
                        
                        ++_i;
                    }
                    
                    vertex_end(_dynamicVBuffer);
                }
                
                ++_j;
            }
        }
    }
    
    #endregion
    
    #region Accumulate lights
    
    static AccumulateLights = function(_cameraL, _cameraT, _cameraR, _cameraB, _cameraCX, _cameraCY, _cameraW, _cameraH)
    {
        if (__freed) return undefined;
        
        #region Linear algebra
        
        //var _view_matrix = matrix_build_lookat(_cameraW/2, _cameraH/2, -16000,   _cameraW/2, _cameraH/2, 0,   0, 1, 0);
        
        //var _view_matrix = [           1,            0,     0, 0,                   // [            1,            0,         0, 0, 
        //                               0,            1,     0, 0,                   //              0,            1,         0, 0, 
        //                               0,            0,     1, 0,                   //              0,            0,         1, 0, 
        //                    -_cameraW/2, -_cameraH/2, 16000, 1 ];                 //   -_cameraW/2, -_cameraH/2, -camera_z, 1]
        
        //var _projMatrix =  matrix_build_projection_ortho(_cameraW, -_cameraH, 1, 32000);
        
        //var _projMatrix = [2/_cameraW,           0,           0,  0,             // [ 2/_cameraW,           0,                      0, 0,
        //                              0, 2/_cameraH,           0,  0,             //             0, 2/_cameraH,                      0, 0,
        //                              0,           0,  1/(32000-1), 0,             //             0,           0,       1/(z_far-z_near), 0,
        //                              0,           0, -1/(32000-1), 1 ];           //             0,           0, -z_near/(z_far-z_near), 1];
        
        //var _vp_matrix = matrix_multiply(_new_view, _new_proj);
        
        //var _vp_matrix = [2/_cameraW,           0,           0, 0,                  // [ 2/_cameraW,            0,                                   0, 0,
        //                            0, 2/_cameraH,           0, 0,                  //             0, -2/_cameraH,                                   0, 0,
        //                            0,           0,     1/31999, 0,                  //             0,            0,                    1/(z_far-z_near), 0,
        //                           -1,           1, 15999/31999, 1 ];                //            -1,            1, (-camera_z - z_near)/(z_far-z_near), 1];
        
        #endregion
        
        //Ultimately, we can use the following projection matrix
        if (__BULB_FLIP_CAMERA_Y)
        {
            //DirectX platforms want the Y-axis flipped
            var _vp_matrix = [2/_cameraW,           0, 0, 0,
                                       0, -2/_cameraH, 0, 0,
                                       0,           0, 0, 0,
                                      -1,           1, 1, 1];
        }
        else
        {
            var _vp_matrix = [2/_cameraW,          0, 0, 0,
                                       0, 2/_cameraH, 0, 0,
                                       0,          0, 0, 0,
                                      -1,         -1, 1, 1];
        }
        
        //We set the view matrix to identity to allow us to use our custom projection matrix
        matrix_set(matrix_view, [1,0,0,0,  0,1,0,0,  0,0,1,0,  0,0,0,1]);
        matrix_set(matrix_projection, _vp_matrix);
            
        //If culling is switched on, shadows will only be cast from the rear faces of occluders
        //This requires careful object placement as not to create weird graphical glitches
        gpu_set_cullmode(((mode == BULB_MODE.HARD_BM_ADD_SELFLIGHTING) || (mode == BULB_MODE.HARD_BM_MAX_SELFLIGHTING))? cull_counterclockwise : cull_noculling);
            
        ///////////Iterate over all non-deferred lights...
        if (mode == BULB_MODE.SOFT_BM_ADD)
        {
            AccumulateSoftLights(_cameraL, _cameraT, _cameraR, _cameraB, _cameraCX, _cameraCY, _cameraW, _cameraH, _vp_matrix);
        }
        else
        {
            AccumulateHardLights(_cameraL, _cameraT, _cameraR, _cameraB, _cameraCX, _cameraCY, _cameraW, _cameraH, _vp_matrix);
        }
        
        //Reset culling so we can draw sprites normally
        gpu_set_cullmode(cull_noculling);
        
        
        
        //Now draw shadow overlay sprites, if we have any
        var _size = array_length(__shadowOverlayArray);
        if (_size > 0)
        {
            if (BULB_SHADOW_OVERLAY_HSV_VALUE_TO_ALPHA)
            {
                shader_set(__shdBulbHSVValueToAlpha);
            }
            else
            {
                //Leverage the fog system to force the colour of the sprites we draw (alpha channel passes through)
                shader_reset();
                gpu_set_fog(true, ambientColor, 0, 0);
            }
            
            //Don't touch the alpha channel
            //TODO - We may need to adjust the alpha channel for use with sharing occlusion values
            gpu_set_colorwriteenable(true, true, true, false);
            
            var _ambientColor = ambientColor;
            var _i = 0;
            repeat(_size)
            {
                var _weak = __shadowOverlayArray[_i];
                if (!weak_ref_alive(_weak) || _weak.ref.__destroyed)
                {
                    array_delete(__shadowOverlayArray, _i, 1);
                }
                else
                {
                    with(_weak.ref)
                    {
                        if (visible)
                        {
                            __CheckSpriteDimensions();
                            
                            //If this light is active, do some drawing
                            if (__IsOnScreen(_cameraL, _cameraT, _cameraR, _cameraB))
                            {
                                //We send the ambient colour over as well even though we have fogging on
                                //This allow us to colour the sprite when using the __shdBulbHSVValueToAlpha shader
                                draw_sprite_ext(sprite, image, x - _cameraL, y - _cameraT, xscale, yscale, angle, _ambientColor, alpha);
                            }
                        }
                    }
                    
                    ++_i;
                }
            }
            
            if (BULB_SHADOW_OVERLAY_HSV_VALUE_TO_ALPHA)
            {
                //Don't use the value->alpha shader carry on
                shader_reset();
            }
            else
            {
                //We're already using the default GM shader, though let's reset the fog value
                gpu_set_fog(false, c_fuchsia, 0, 0);
            }
        }
        else
        {
            //If we're not drawing any shadow overlays, reset what shader we're using
            shader_reset();
        }
        
        
        
        //Finally, draw light overlay sprites too
        //We use the overarching blend mode for the renderer
        if ((mode == BULB_MODE.HARD_BM_MAX) || (mode == BULB_MODE.HARD_BM_MAX_SELFLIGHTING))
        {
            gpu_set_blendmode(bm_max);
        }
        else
        {
            gpu_set_blendmode(bm_add);
        }
        
        //Don't touch the alpha channel though
        gpu_set_colorwriteenable(true, true, true, false);
        
        var _i = 0;
        repeat(array_length(__lightOverlayArray))
        {
            var _weak = __lightOverlayArray[_i];
            if (!weak_ref_alive(_weak) || _weak.ref.__destroyed)
            {
                array_delete(__lightOverlayArray, _i, 1);
            }
            else
            {
                with(_weak.ref)
                {
                    if (visible)
                    {
                        __CheckSpriteDimensions();
                        
                        //If this light is active, do some drawing
                        if (__IsOnScreen(_cameraL, _cameraT, _cameraR, _cameraB))
                        {
                            draw_sprite_ext(sprite, image, x - _cameraL, y - _cameraT, xscale, yscale, angle, blend, alpha);
                        }
                    }
                }
                
                ++_i;
            }
        }
        
        
        
        //Restore default behaviour
        gpu_set_colorwriteenable(true, true, true, true);
        gpu_set_blendmode(bm_normal);
    }
    
    #endregion
    
    #region Accumulate soft lights
    
    static AccumulateSoftLights = function(_cameraL, _cameraT, _cameraR, _cameraB, _cameraCX, _cameraCY, _cameraW, _cameraH, _vp_matrix)
    {
        if (__freed) return undefined;
        
        var _wipeVBuffer = __wipeVBuffer;
        var _groupArray  = __groupArray;
        var _groupCount  = __maxGroups;
        
        //Calculate some transform coefficients
        var _cameraInvW = 2/_cameraW;
        var _cameraInvH = 2/_cameraH;
        if (__BULB_FLIP_CAMERA_Y) _cameraInvH = -_cameraInvH;
        
        var _cameraTransformedX = _cameraCX*_cameraInvW;
        var _cameraTransformedY = _cameraCY*_cameraInvH;
        
        //Pre-build a custom projection matrix
        //[8] [9] [10] are set per light
        var _projMatrix = [        _cameraInvW,                   0,          0,  0,
                                             0,         _cameraInvH,          0,  0,
                                     undefined,           undefined,  undefined, -1,
                           -_cameraTransformedX, -_cameraTransformedY,          0,  1];
        
        // xOut = (x - z*(camX - lightX) - camX) / camW
        // yOut = (y - z*(camY - lightY) - camY) / camH
        // zOut = 0
        
        var _i = 0;
        repeat(array_length(__lightsArray))
        {
            var _weak = __lightsArray[_i];
            if (!weak_ref_alive(_weak) || _weak.ref.__destroyed)
            {
                array_delete(__lightsArray, _i, 1);
            }
            else
            {
                with(_weak.ref)
                {
                    if (visible)
                    {
                        __CheckSpriteDimensions();
                        
                        //If this light is active, do some drawing
                        if (__IsOnScreen(_cameraL, _cameraT, _cameraR, _cameraB))
                        {
                            if (castShadows)
                            {
                                gpu_set_colorwriteenable(false, false, false, true);
                                
                                //Clear alpha channel
                                gpu_set_blendmode(bm_subtract);
                                
                                if (__BULB_PARTIAL_CLEAR)
                                {
                                    draw_sprite_ext(sprite, image,
                                                    x - _cameraL, y - _cameraT,
                                                    xscale, yscale, angle,
                                                    c_black, 1);
                                }
                                else
                                {
                                    vertex_submit(_wipeVBuffer, pr_trianglelist, -1);
                                }
                                
                                //Render shadows
                                shader_set(__shdBulbSoftShadows);
                                gpu_set_blendmode(bm_add);
                                _projMatrix[@  8] = x;
                                _projMatrix[@  9] = y;
                                _projMatrix[@ 10] = penumbraSize;
                                matrix_set(matrix_projection, _projMatrix);
                                
                                var _j = 0;
                                repeat(_groupCount)
                                {
                                    if ((bitmask & (1 << _j)) > 0)
                                    {
                                        with(_groupArray[_j])
                                        {
                                            vertex_submit(staticVBuffer,  pr_trianglelist, -1);
                                            vertex_submit(dynamicVBuffer, pr_trianglelist, -1);
                                        }
                                    }
                                    
                                    ++_j;
                                }
                                
                                //Draw light sprite
                                shader_reset();
                                matrix_set(matrix_projection, _vp_matrix);
                                
                                if (alpha < 1.0)
                                {
                                    //If this light is fading out, adjust the destination alpha channel
                                    //TODO - Do this earlier during the wipe phase and before shadow casting
                                    gpu_set_blendmode_ext(bm_src_alpha, bm_one);
                                    draw_sprite_ext(sprite, image,
                                                    x - _cameraL, y - _cameraT,
                                                    xscale, yscale, angle,
                                                    blend, 1.0 - alpha);
                                }
                                
                                gpu_set_colorwriteenable(true, true, true, false);
                                gpu_set_blendmode_ext(bm_inv_dest_alpha, bm_one);
                                
                                draw_sprite_ext(sprite, image,
                                                x - _cameraL, y - _cameraT,
                                                xscale, yscale, angle,
                                                blend, alpha);
                            }
                            else
                            {
                                gpu_set_blendmode(bm_add);
                                draw_sprite_ext(sprite, image,
                                                x - _cameraL, y - _cameraT,
                                                xscale, yscale, angle,
                                                blend, alpha);
                            }
                        }
                    }
                }
                
                ++_i;
            }
        }
        
        var _aspectRatio = _cameraW/_cameraH;
        var _i = 0;
        repeat(array_length(__sunlightArray))
        {
            var _weak = __sunlightArray[_i];
            if (!weak_ref_alive(_weak) || _weak.ref.__destroyed)
            {
                array_delete(__sunlightArray, _i, 1);
            }
            else
            {
                with(_weak.ref)
                {
                    if (visible)
                    {
                        //Clear alpha channel
                        gpu_set_colorwriteenable(false, false, false, true);
                        gpu_set_blendmode(bm_subtract);
                        vertex_submit(_wipeVBuffer, pr_trianglelist, -1);
                        
                        //Render shadows
                        shader_set(__shdBulbSoftShadowsSunlight);
                        gpu_set_blendmode(bm_add);
                        _projMatrix[@  8] = -__BULB_SUNLIGHT_SCALE*dcos(angle);
                        _projMatrix[@  9] = -__BULB_SUNLIGHT_SCALE*dsin(angle);
                        _projMatrix[@ 10] = __BULB_SOFT_SUNLIGHT_PENUMBRA_SCALE*penumbraSize;
                        _projMatrix[@ 11] = _aspectRatio;
                        matrix_set(matrix_projection, _projMatrix);
                        
                        var _j = 0;
                        repeat(_groupCount)
                        {
                            if ((bitmask & (1 << _j)) > 0)
                            {
                                with(_groupArray[_j])
                                {
                                    vertex_submit(staticVBuffer,  pr_trianglelist, -1);
                                    vertex_submit(dynamicVBuffer, pr_trianglelist, -1);
                                }
                            }
                            
                            ++_j;
                        }
                        
                        //Draw light sprite
                        shader_reset();
                        matrix_set(matrix_projection, _vp_matrix);
                        
                        if (alpha < 1.0)
                        {
                            //If this light is fading out, adjust the destination alpha channel
                            //TODO - Do this earlier during the wipe phase and before shadow casting
                            gpu_set_blendmode_ext(bm_src_alpha, bm_one);
                            draw_sprite_ext(__sprBulbPixel, 0, 0, 0, _cameraW, _cameraH, 0, blend, 1-alpha);
                        }
                        
                        gpu_set_colorwriteenable(true, true, true, false);
                        gpu_set_blendmode_ext(bm_inv_dest_alpha, bm_one);
                        draw_sprite_ext(__sprBulbPixel, 0, 0, 0, _cameraW, _cameraH, 0, blend, alpha);
                    }
                }
                
                ++_i;
            }
        }
        
        gpu_set_blendmode(bm_normal);
    }
    
    #endregion
    
    #region Accumulate hard lights
    
    static AccumulateHardLights = function(_cameraL, _cameraT, _cameraR, _cameraB, _cameraCX, _cameraCY, _cameraW, _cameraH, _vp_matrix)
    {
        if (__freed) return undefined;
        
        var _wipeVBuffer = __wipeVBuffer;
        var _groupArray  = __groupArray;
        var _groupCount  = __maxGroups;
        
        //Calculate some transform coefficients
        var _cameraInvW = 2/_cameraW;
        var _cameraInvH = 2/_cameraH;
        if (__BULB_FLIP_CAMERA_Y) _cameraInvH = -_cameraInvH;
        
        var _cameraTransformedX = _cameraCX*_cameraInvW;
        var _cameraTransformedY = _cameraCY*_cameraInvH;
        
        //Pre-build a custom projection matrix
        //[8] [9] are set per light
        var _projMatrix = [         _cameraInvW,                    0, 0,  0,
                                              0,          _cameraInvH, 0,  0,
                                      undefined,            undefined, 0, -1,
                           -_cameraTransformedX, -_cameraTransformedY, 0,  1];
        
        // xOut = (x - z*(camX - lightX) - camX) / camW
        // yOut = (y - z*(camY - lightY) - camY) / camH
        // zOut = 0
        
        gpu_set_ztestenable(true);
        gpu_set_zwriteenable(true);
        
        if ((mode == BULB_MODE.HARD_BM_MAX) || (mode == BULB_MODE.HARD_BM_MAX_SELFLIGHTING))
        {
            gpu_set_blendmode(bm_max);
            var _resetShader = __shdBulbPremultiplyAlpha;
        }
        else
        {
            gpu_set_blendmode(bm_add);
            var _resetShader = __shdBulbPassThrough;
        }
        
        shader_set(_resetShader);
        matrix_set(matrix_projection, _vp_matrix);
        
        var _i = 0;
        repeat(array_length(__lightsArray))
        {
            var _weak = __lightsArray[_i];
            if (!weak_ref_alive(_weak) || _weak.ref.__destroyed)
            {
                array_delete(__lightsArray, _i, 1);
            }
            else
            {
                with(_weak.ref)
                {
                    if (visible)
                    {
                        __CheckSpriteDimensions();
                        
                        //If this light is active, do some drawing
                        if (__IsOnScreen(_cameraL, _cameraT, _cameraR, _cameraB))
                        {
                            if (castShadows)
                            {
                                //Draw shadow stencil
                                gpu_set_zfunc(cmpfunc_always);
                                gpu_set_colorwriteenable(false, false, false, false);
                                
                                //Reset zbuffer
                                if (__BULB_PARTIAL_CLEAR)
                                {
                                    draw_sprite_ext(sprite, image,
                                                    x - _cameraL, y - _cameraT,
                                                    xscale, yscale, angle,
                                                    c_black, 1);
                                    shader_set(__shdBulbHardShadows);
                                }
                                else
                                {
                                    shader_set(__shdBulbHardShadows);
                                    vertex_submit(_wipeVBuffer, pr_trianglelist, -1);
                                }
                                
                                //Render shadows
                                _projMatrix[@ 8] = _cameraTransformedX - x*_cameraInvW;
                                _projMatrix[@ 9] = _cameraTransformedY - y*_cameraInvH;
                                matrix_set(matrix_projection, _projMatrix);
                                
                                var _j = 0;
                                repeat(_groupCount)
                                {
                                    if ((bitmask & (1 << _j)) > 0)
                                    {
                                        with(_groupArray[_j])
                                        {
                                            vertex_submit(staticVBuffer,  pr_trianglelist, -1);
                                            vertex_submit(dynamicVBuffer, pr_trianglelist, -1);
                                        }
                                    }
                                    
                                    ++_j;
                                }
                                
                                //Draw light sprite
                                shader_set(_resetShader);
                                gpu_set_zfunc(cmpfunc_lessequal);
                                gpu_set_colorwriteenable(true, true, true, false);
                                matrix_set(matrix_projection, _vp_matrix);
                                
                                draw_sprite_ext(sprite, image,
                                                x - _cameraL, y - _cameraT,
                                                xscale, yscale, angle,
                                                blend, alpha);
                            }
                            else
                            {
                                gpu_set_zfunc(cmpfunc_always);
                                draw_sprite_ext(sprite, image,
                                                x - _cameraL, y - _cameraT,
                                                xscale, yscale, angle,
                                                blend, alpha);
                            }
                        }
                    }
                }
                
                ++_i;
            }
        }
        
        var _aspectRatio = _cameraW/_cameraH;
        var _i = 0;
        repeat(array_length(__sunlightArray))
        {
            var _weak = __sunlightArray[_i];
            if (!weak_ref_alive(_weak) || _weak.ref.__destroyed)
            {
                array_delete(__sunlightArray, _i, 1);
            }
            else
            {
                with(_weak.ref)
                {
                    if (visible)
                    {
                        //Draw shadow stencil
                        gpu_set_zfunc(cmpfunc_always);
                        gpu_set_colorwriteenable(false, false, false, false);
                        
                        //Reset zbuffer
                        shader_set(__shdBulbHardShadows);
                        vertex_submit(_wipeVBuffer, pr_trianglelist, -1);
                        
                        //Render shadows
                        _projMatrix[@ 8] = -__BULB_SUNLIGHT_SCALE*dcos(angle);
                        _projMatrix[@ 9] = -__BULB_SUNLIGHT_SCALE*dsin(angle)*_aspectRatio;
                        matrix_set(matrix_projection, _projMatrix);
                        
                        var _j = 0;
                        repeat(_groupCount)
                        {
                            if ((bitmask & (1 << _j)) > 0)
                            {
                                with(_groupArray[_j])
                                {
                                    vertex_submit(staticVBuffer,  pr_trianglelist, -1);
                                    vertex_submit(dynamicVBuffer, pr_trianglelist, -1);
                                }
                            }
                            
                            ++_j;
                        }
                        
                        //Draw fullscreen light sprite
                        shader_set(_resetShader);
                        gpu_set_zfunc(cmpfunc_lessequal);
                        gpu_set_colorwriteenable(true, true, true, false);
                        matrix_set(matrix_projection, _vp_matrix);
                        
                        draw_sprite_ext(__sprBulbPixel, 0, 0, 0, _cameraW, _cameraH, 0, blend, alpha);
                    }
                }
                
                ++_i;
            }
        }
        
        gpu_set_blendmode(bm_normal);
        gpu_set_ztestenable(false);
        gpu_set_zwriteenable(false);
    }
    
    static __FreeVertexBuffers = function()
    {
        if (__wipeVBuffer != undefined)
        {
            vertex_delete_buffer(__wipeVBuffer);
            __wipeVBuffer = undefined;
        }
        
        var _i = 0;
        repeat(__maxGroups)
        {
            with(__groupArray[_i])
            {
                if (staticVBuffer != undefined)
                {
                    vertex_delete_buffer(staticVBuffer);
                    staticVBuffer = undefined;
                }
                
                if (dynamicVBuffer != undefined)
                {
                    vertex_delete_buffer(dynamicVBuffer);
                    dynamicVBuffer = undefined;
                }
            }
            
            ++_i;
        }
    }
    
    static __FreeSurface = function()
    {
        if ((__surface != undefined) && surface_exists(__surface))
        {
            surface_free(__surface);
            __surface = undefined;
        }
    }
    
    #endregion
    
    #region Clip Surface
    
    static __ApplyClippingSurface = function()
    {
        if (__freed || !__clipEnabled) return undefined;
        
        var _clipSurface = GetClippingSurface();
        if (_clipSurface != undefined)
        {
            if (!__clipInvert) //Intended to be (!__clipInvert)
            {
                //Use an inverse alpha so that we paint visible areas onto the clip surface
                //Inverted mode should use GameMaker's standard alpha blending
                //...this makes sense if you think about it, trust me
                gpu_set_blendmode_ext(bm_inv_src_alpha, bm_src_alpha);
            }
            
            gpu_set_colorwriteenable(true, true, true, false);
            
            if (__clipValueToAlpha)
            {
                //Apply the HSV value->alpha conversion shader if so desired
                shader_set(__shdBulbHSVValueToAlpha);
                draw_surface_ext(_clipSurface, 0, 0, 1, 1, 0, __clipIsShadow? ambientColor : c_white, __clipAlpha);
                shader_reset();
            }
            else
            {
                draw_surface_ext(_clipSurface, 0, 0, 1, 1, 0, __clipIsShadow? ambientColor : c_white, __clipAlpha);
            }
            
            //Reset GPU state
            gpu_set_blendmode(bm_normal);
            gpu_set_colorwriteenable(true, true, true, true);
        }
    }
    
    #endregion
}