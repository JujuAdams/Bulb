/// @param ambientColour
/// @param mode
/// @param smooth
/// @param [useNormalMap=false]

enum BULB_MODE
{
    HARD_BM_ADD,
    HARD_BM_ADD_SELFLIGHTING,
    HARD_BM_MAX,
    HARD_BM_MAX_SELFLIGHTING,
    SOFT_BM_ADD,
    __SIZE
}

function BulbRenderer(_ambientColour, _mode, _smooth, _useNormalMap = false) constructor
{
    //Assign the ambient colour used for the darkest areas of the screen. This can be changed on the fly
    ambientColor = _ambientColour;
    
    //The smoothing mode controls texture filtering both when accumulating lights and when drawing the resulting surface
    smooth = _smooth;
    
    mode = _mode;
    
    surfaceWidth  = -1;
    surfaceHeight = -1;
    
    //Initialise variables used and updated in .__UpdateVertexBuffers()
    __staticVBuffer  = undefined; //Vertex buffer describing the geometry of static occluder objects
    __dynamicVBuffer = undefined; //As above but for dynamic shadow occluders. This is updated every step
    __wipeVBuffer    = undefined; //This vertex buffer is used to reset the z-buffer during accumulation of non-deferred lights
    __surface        = undefined; //Screen-space surface for final accumulation of lights
    
    __usingNormalMap = _useNormalMap;
    __normalSurface  = undefined; //Screen-space surface that stores normals. This may stay <undefined> if no normal map is ever added
    __oldTexFilter   = undefined;
    
    __staticOccludersArray  = [];
    __dynamicOccludersArray = [];
    __lightsArray           = [];
    
    __freed = false;
    __oldMode = undefined;
    
    
    
    #region Public Methods
    
    static SetAmbientColor = function(_color)
    {
        ambientColor = _color;
    }
    
    static GetAmbientColor = function()
    {
        return ambientColor;
    }
    
    static StartDrawingToNormalMapFromCamera = function(_camera, _clear)
    {
        var _viewMatrix = camera_get_view_mat(_camera);
        var _projMatrix = camera_get_proj_mat(_camera);
        
        //Deploy PROPER MATHS in case the dev is using matrices
        var _cameraX          = -_viewMatrix[12];
        var _cameraY          = -_viewMatrix[13];
        var _cameraViewWidth  = round(abs(2/_projMatrix[0]));
        var _cameraViewHeight = round(abs(2/_projMatrix[5]));
        var _cameraLeft       = _cameraX - _cameraViewWidth/2;
        var _cameraTop        = _cameraY - _cameraViewHeight/2;
        
        return StartDrawingToNormalMap(_cameraLeft, _cameraTop, _cameraViewWidth, _cameraViewHeight, _clear);
    }
    
    static StartDrawingToNormalMap = function(_cameraL, _cameraT, _cameraW, _cameraH, _clear)
    {
        if (!__usingNormalMap) __BulbError("Normal map was not added to this renderer when instantiated");
        
        if (surfaceWidth  <= 0) surfaceWidth  = _cameraW;
        if (surfaceHeight <= 0) surfaceHeight = _cameraH;
        
        __oldTexFilter = gpu_get_tex_filter();
        gpu_set_tex_filter(smooth);
        
        surface_set_target(GetNormalMapSurface());
        //FIXME - GameMaker is fucking stupid and aggressively culls sprite calls that it shouldn't
        //        This should be implemented used the view matrix but instead we have to workaround by using the world matrix
        matrix_set(matrix_world, matrix_build(-_cameraL, -_cameraT, 0,   0,0,0,   1,1,1));
        if (_clear) draw_clear(__BULB_NORMAL_CLEAR_COLOUR);
        shader_set(__shdBulbTransformNormal);
    }
    
    static StopDrawingToNormalMap = function()
    {
        if (__oldTexFilter == undefined)
        {
            __BulbError("Must call .StopDrawingToNormalMap() after .StartDrawingToNormalMap*()");
        }
        
        surface_reset_target();
        shader_reset();
        
        matrix_set(matrix_world, matrix_build_identity());
        
        gpu_set_tex_filter(__oldTexFilter);
        __oldTexFilter = undefined;
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
    
    static GetNormalMapSurface = function()
    {
        if (__freed) return undefined;
        
        if (!__usingNormalMap)
        {
            __BulbError("No normal map has been added to this renderer");
            return undefined;
        }
        
        if ((surfaceWidth <= 0) || (surfaceHeight <= 0)) return undefined;
        
        if ((__normalSurface != undefined) && ((surface_get_width(__normalSurface) != surfaceWidth) || (surface_get_height(__normalSurface) != surfaceHeight)))
        {
            surface_free(__normalSurface);
            __normalSurface = undefined;
        }
        
        if ((__normalSurface == undefined) || !surface_exists(__normalSurface))
        {
            __normalSurface = surface_create(surfaceWidth, surfaceHeight);
            
            surface_set_target(__normalSurface);
            draw_clear_alpha(__BULB_NORMAL_CLEAR_COLOUR, 1.0);
            surface_reset_target();
        }
        
        return __normalSurface;
    }
    
    static RefreshStaticOccluders = function()
    {
        if (__freed) return undefined;
        
        if (__staticVBuffer != undefined)
        {
            vertex_delete_buffer(__staticVBuffer);
            __staticVBuffer = undefined;
        }
    }
    
    static Free = function()
    {
        __FreeVertexBuffers();
        __FreeSurface();
        __FreeNormalMapSurface();
        
        __freed = true;
    }
    
    #endregion
    
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
            vertex_begin(__wipeVBuffer, global.__bulbFormat3DColour);
            
            vertex_position_3d(__wipeVBuffer,          0,          0, 0); vertex_colour(__wipeVBuffer, c_black, 1);
            vertex_position_3d(__wipeVBuffer, 2*_cameraW,          0, 0); vertex_colour(__wipeVBuffer, c_black, 1);
            vertex_position_3d(__wipeVBuffer,          0, 2*_cameraH, 0); vertex_colour(__wipeVBuffer, c_black, 1);
            
            vertex_end(__wipeVBuffer);
            vertex_freeze(__wipeVBuffer);
        }
        
        //One-time construction of the static occluder geometry
        if (__staticVBuffer == undefined)
        {
            //Create a new vertex buffer
            __staticVBuffer = vertex_create_buffer();
            var _staticVBuffer = __staticVBuffer;
            
            //Add static shadow caster vertices to the relevant vertex buffer
            if (mode == BULB_MODE.SOFT_BM_ADD)
            {
                vertex_begin(__staticVBuffer, global.__bulbFormat3DTexture);
                
                var _array = __staticOccludersArray;
                var _i = 0;
                repeat(array_length(_array))
                {
                    var _weak = _array[_i];
                    if (!weak_ref_alive(_weak) || _weak.ref.__destroyed)
                    {
                        array_delete(_array, _i, 1);
                    }
                    else
                    {
                        with(_weak.ref) __BulbAddOcclusionSoft(_staticVBuffer);
                        ++_i;
                    }
                }
            }
            else
            {
                vertex_begin(__staticVBuffer, global.__bulbFormat3DColour);
                
                var _array = __staticOccludersArray;
                var _i = 0;
                repeat(array_length(_array))
                {
                    var _weak = _array[_i];
                    if (!weak_ref_alive(_weak) || _weak.ref.__destroyed)
                    {
                        array_delete(_array, _i, 1);
                    }
                    else
                    {
                        with(_weak.ref) __BulbAddOcclusionHard(_staticVBuffer);
                        ++_i;
                    }
                }
            }
            
            vertex_end(__staticVBuffer);
            
            //Freeze this buffer for speed boosts later on (though only if we have vertices in this buffer)
            if (vertex_get_number(__staticVBuffer) > 0) vertex_freeze(__staticVBuffer);
        }
        
        //Refresh the dynamic occluder geometry
        if (__dynamicVBuffer == undefined) __dynamicVBuffer = vertex_create_buffer();
        var _dynamicVBuffer = __dynamicVBuffer;
        
        //Add dynamic occluder vertices to the relevant vertex buffer
        if (mode == BULB_MODE.SOFT_BM_ADD)
        {
            vertex_begin(_dynamicVBuffer, global.__bulbFormat3DTexture);
            
            var _array = __dynamicOccludersArray;
            var _i = 0;
            repeat(array_length(_array))
            {
                var _weak = _array[_i];
                if (!weak_ref_alive(_weak) || _weak.ref.__destroyed)
                {
                    array_delete(_array, _i, 1);
                }
                else
                {
                    with(_weak.ref)
                    {
                        if (__IsOnScreen(_cameraExpL, _cameraExpT, _cameraExpR, _cameraExpB)) __BulbAddOcclusionSoft(_dynamicVBuffer);
                    }
                    
                    ++_i;
                }
            }
        }
        else
        {
            vertex_begin(_dynamicVBuffer, global.__bulbFormat3DColour);
            
            var _array = __dynamicOccludersArray;
            var _i = 0;
            repeat(array_length(_array))
            {
                var _weak = _array[_i];
                if (!weak_ref_alive(_weak) || _weak.ref.__destroyed)
                {
                    array_delete(_array, _i, 1);
                }
                else
                {
                    with(_weak.ref)
                    {
                        if (__IsOnScreen(_cameraExpL, _cameraExpT, _cameraExpR, _cameraExpB)) __BulbAddOcclusionHard(_dynamicVBuffer);
                    }
                    
                    ++_i;
                }
            }
        }
        
        vertex_end(_dynamicVBuffer);
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
            
        //Reset GPU properties
        shader_reset();
        gpu_set_colorwriteenable(true, true, true, true);
        gpu_set_cullmode(cull_noculling);
    }
    
    #endregion
    
    #region Accumulate soft lights
    
    static AccumulateSoftLights = function(_cameraL, _cameraT, _cameraR, _cameraB, _cameraCX, _cameraCY, _cameraW, _cameraH, _vp_matrix)
    {
        if (__freed) return undefined;
        
        var _wipeVBuffer    = __wipeVBuffer;
        var _staticVBuffer  = __staticVBuffer;
        var _dynamicVBuffer = __dynamicVBuffer;
        
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
        
        var _usingNormalMap = __usingNormalMap;
        if (_usingNormalMap)
        {
            shader_set(__shdBulbSoftNormal);
            var _normalMapTexture = surface_get_texture(GetNormalMapSurface());
            texture_set_stage(shader_get_sampler_index(__shdBulbSoftNormal, "u_sNormalMap"), _normalMapTexture);
            shader_reset();
        }
        
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
                    __CheckSpriteDimensions();
                    
                    //If this light is active, do some drawing
                    if (__IsOnScreen(_cameraL, _cameraT, _cameraR, _cameraB))
                    {
                        if (castShadows)
                        {
                            shader_reset();
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
                            vertex_submit(_staticVBuffer,  pr_trianglelist, -1);
                            vertex_submit(_dynamicVBuffer, pr_trianglelist, -1);
                            
                            matrix_set(matrix_projection, _vp_matrix);
                            
                            //Add the influence of the normal map
                            if (_usingNormalMap)
                            {
                                shader_set(__shdBulbSoftNormal);
                                texture_set_stage(shader_get_sampler_index(__shdBulbSoftNormal, "u_sNormalMap"), _normalMapTexture);
                                shader_set_uniform_f(shader_get_uniform(__shdBulbSoftNormal, "u_vLightPos"), x - _cameraL, y - _cameraT, 100);
                                
                                draw_sprite_ext(sprite, image,
                                                x - _cameraL, y - _cameraT,
                                                xscale, yscale, angle,
                                                blend, alpha);
                            }
                            
                            //Draw light sprite
                            shader_reset();
                            
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
                            
                            if (_usingNormalMap)
                            {
                                shader_set(__shdBulbPassThroughWithNormalMap);
                                texture_set_stage(shader_get_sampler_index(__shdBulbPassThroughWithNormalMap, "u_sNormalMap"), _normalMapTexture);
                                shader_set_uniform_f(shader_get_uniform(__shdBulbPassThroughWithNormalMap, "u_vLightPos"), x - _cameraL, y - _cameraT, 100);
                                
                                draw_sprite_ext(sprite, image,
                                                x - _cameraL, y - _cameraT,
                                                xscale, yscale, angle,
                                                blend, alpha);
                                
                                shader_reset();
                            }
                            else
                            {
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
        
        gpu_set_blendmode(bm_normal);
    }
    
    #endregion
    
    #region Accumulate hard lights
    
    static AccumulateHardLights = function(_cameraL, _cameraT, _cameraR, _cameraB, _cameraCX, _cameraCY, _cameraW, _cameraH, _vp_matrix)
    {
        if (__freed) return undefined;
        
        var _wipeVBuffer    = __wipeVBuffer;
        var _staticVBuffer  = __staticVBuffer;
        var _dynamicVBuffer = __dynamicVBuffer;
        
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
        
        var _usingNormalMap = __usingNormalMap;
        
        if ((mode == BULB_MODE.HARD_BM_MAX) || (mode == BULB_MODE.HARD_BM_MAX_SELFLIGHTING))
        {
            gpu_set_blendmode(bm_max);
            var _resetShader = _usingNormalMap? __shdBulbPremultiplyAlphaWithNormalMap : __shdBulbPremultiplyAlpha;
        }
        else
        {
            gpu_set_blendmode(bm_add);
            var _resetShader = _usingNormalMap? __shdBulbPassThroughWithNormalMap : __shdBulbPassThrough;
        }
        
        shader_set(_resetShader);
        matrix_set(matrix_projection, _vp_matrix);
        
        if (_usingNormalMap)
        {
            var _normalMapTexture = surface_get_texture(GetNormalMapSurface());
            texture_set_stage(shader_get_sampler_index(_resetShader, "u_sNormalMap"), _normalMapTexture);
        }
        
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
                            vertex_submit(_staticVBuffer,  pr_trianglelist, -1);
                            vertex_submit(_dynamicVBuffer, pr_trianglelist, -1);
                            
                            //Draw light sprite
                            shader_set(_resetShader);
                            gpu_set_zfunc(cmpfunc_lessequal);
                            gpu_set_colorwriteenable(true, true, true, false);
                            matrix_set(matrix_projection, _vp_matrix);
                            
                            if (_usingNormalMap)
                            {
                                texture_set_stage(shader_get_sampler_index(_resetShader, "u_sNormalMap"), _normalMapTexture);
                                shader_set_uniform_f(shader_get_uniform(_resetShader, "u_vLightPos"), x - _cameraL, y - _cameraT, z);
                            }
                            
                            draw_sprite_ext(sprite, image,
                                            x - _cameraL, y - _cameraT,
                                            xscale, yscale, angle,
                                            blend, alpha);
                        }
                        else
                        {
                            if (_usingNormalMap)
                            {
                                shader_set_uniform_f(shader_get_uniform(_resetShader, "u_vLightPos"), x - _cameraL, y - _cameraT, z);
                            }
                            
                            gpu_set_zfunc(cmpfunc_always);
                            draw_sprite_ext(sprite, image,
                                            x - _cameraL, y - _cameraT,
                                            xscale, yscale, angle,
                                            blend, alpha);
                        }
                    }
                }
                
                ++_i;
            }
        }
        
        shader_reset();
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
    
    static __FreeNormalMapSurface = function()
    {
        if ((__normalSurface != undefined) && surface_exists(__normalSurface))
        {
            surface_free(__normalSurface);
            __normalSurface = undefined;
        }
    }
    
    #endregion
}