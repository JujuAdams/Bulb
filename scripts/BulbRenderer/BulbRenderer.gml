function BulbRenderer() constructor
{
    //Assign the ambient colour used for the darkest areas of the screen. This can be changed on the fly
    ambientColor = c_black;
    
    //The smoothing mode controls texture filtering both when accumulating lights and when drawing the resulting surface
    smooth = gpu_get_tex_filter();
    
    selfLighting = false;
    
    soft = false;
    
    hdr         = false;
    hdrExposure = 1;
    hdrTonemap  = BULB_TONEMAP_REINHARD_EXTENDED;
    
    __oldSoft = undefined;
    __oldHDR  = undefined;
    
    surfaceWidth  = -1;
    surfaceHeight = -1;
    
    //Initialise variables used and updated in .__UpdateVertexBuffers()
    __staticVBuffer  = undefined; //Vertex buffer describing the geometry of static occluder objects
    __dynamicVBuffer = undefined; //As above but for dynamic shadow occluders. This is updated every step
    __surface        = undefined; //Screen-space surface for final accumulation of lights
    
    __staticOccludersArray  = [];
    __dynamicOccludersArray = [];
    __lightsArray           = [];
    __sunlightArray         = [];
    __ambienceSpriteArray   = [];
    __shadowOverlayArray    = [];
    __lightOverlayArray     = [];
    
    __freed = false;
    
    __hdrSurface = undefined;
    
    
    
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
        
        static _worldMatrix = [1,0,0,0,   0,1,0,0,   0,0,1,0,   0,0,0,1];
        
        if (surfaceWidth  <= 0) surfaceWidth  = _cameraW;
        if (surfaceHeight <= 0) surfaceHeight = _cameraH;
        
        if (soft != __oldSoft)
        {
            __oldSoft = soft;
            __FreeVertexBuffers();
        }
        
        if (hdr != __oldHDR)
        {
            __oldHDR = hdr;
            
            if (__surface != undefined)
            {
                surface_free(__surface);
                __surface = undefined;
            }
            
            if (not hdr)
            {
                __FreeHDRSurface();
            }
        }
        
        var _cameraR  = _cameraL + _cameraW;
        var _cameraB  = _cameraT + _cameraH;
        var _cameraCX = _cameraL + 0.5*_cameraW;
        var _cameraCY = _cameraT + 0.5*_cameraH;
        
        //Construct our wipe/static/dynamic vertex buffers
        __UpdateVertexBuffers(_cameraL, _cameraT, _cameraR, _cameraB, _cameraW, _cameraH);
        
        //Create accumulating lighting __surface
        surface_set_target(GetSurface());
        
        gpu_set_cullmode(cull_noculling);
        
        //Really we should use the view matrix for this, but GameMaker's sprite culling is fucked
        //If we use a proper view matrix then lighting sprites are culling, leading to no lighting being drawn
        _worldMatrix[@ 12] = -_cameraL;
        _worldMatrix[@ 13] = -_cameraT;
        matrix_set(matrix_world, _worldMatrix);
        
        //Record the current texture filter state, then set our new filter state
        var _old_tex_filter = gpu_get_tex_filter();
        gpu_set_tex_filter(smooth);
        
        //Clear the __surface with the ambient colour
        draw_clear(ambientColor);
        
        //If we're not forcing deferred rendering everywhere, update those lights
        __AccumulateLights(_cameraL, _cameraT, _cameraR, _cameraB, _cameraCX, _cameraCY, _cameraW, _cameraH);
        
        //Restore the old filter state
        gpu_set_tex_filter(_old_tex_filter);
        
        surface_reset_target();
        matrix_set(matrix_world, matrix_build_identity());
    }
    
    static DrawLitSurface = function(_surface, _x, _y, _width, _height, _textureFiltering = undefined, _alphaBlend = undefined)
    {
        var _oldTextureFiltering = gpu_get_tex_filter();
        
        if (_textureFiltering != undefined)
        {
            gpu_set_tex_filter(_textureFiltering);
        }
        
        if (_alphaBlend != undefined)
        {
            var _oldAlphaBlend = gpu_get_tex_filter();
            gpu_set_blendenable(_alphaBlend);
        }
        
        if (hdr)
        {
            var _surfaceWidth  = surface_get_width( _surface);
            var _surfaceHeight = surface_get_height(_surface);
            
            __GetHDRSurface(_surfaceWidth, _surfaceHeight);
            
            gpu_set_colorwriteenable(true, true, true, false);
            
            shader_set(__shdBulbGammaToLinear);
            surface_copy(__hdrSurface, 0, 0, _surface);
            shader_reset();
            
            surface_set_target(__hdrSurface);
            gpu_set_blendmode_ext(bm_zero, bm_src_color);
            draw_surface_stretched(__surface, 0, 0, _surfaceWidth, _surfaceHeight);
            gpu_set_blendmode(bm_normal);
            surface_reset_target();
            
            gpu_set_colorwriteenable(true, true, true, true);
            
            if (hdrTonemap == BULB_TONEMAP_REINHARD)
            {
                var _shader = __shdBulbTonemapReinhard;
            }
            else if (hdrTonemap == BULB_TONEMAP_REINHARD_EXTENDED)
            {
                var _shader = __shdBulbTonemapReinhardExtended;
            }
            else if (hdrTonemap == BULB_TONEMAP_ACES)
            {
                var _shader = __shdBulbTonemapACES;
            }
            else
            {
                var _shader = __shdBulbLinearToGamma;
            }
            
            shader_set(_shader);
            shader_set_uniform_f(shader_get_uniform(_shader, "u_fExposure"), hdrExposure);
            draw_surface_stretched(__hdrSurface, _x, _y, _width, _height);
            shader_reset();
        }
        else
        {
            draw_surface_stretched(_surface, _x, _y, _width, _height);
        }
            
        if (_textureFiltering != undefined)
        {
            gpu_set_tex_filter(_oldTextureFiltering);
        }
        
        if (_alphaBlend != undefined)
        {
            gpu_set_blendenable(_oldAlphaBlend);
        }
        
        if (not hdr)
        {
            if ((__surface != undefined) && surface_exists(__surface))
            {
                gpu_set_tex_filter(smooth);
                gpu_set_blendmode_ext(bm_dest_color, bm_zero);
                gpu_set_colorwriteenable(true, true, true, false);
                
                draw_surface_stretched(__surface, _x, _y, _width, _height);
                
                gpu_set_tex_filter(_oldTextureFiltering);
                gpu_set_blendmode(bm_normal);
                gpu_set_colorwriteenable(true, true, true, true);
                
                //Restore the old filter state
            }
        }
    }
    
    static __GetHDRSurface = function(_width, _height)
    {
        if (__freed) return undefined;
        if ((_width <= 0) || (_height <= 0)) return undefined;
        
        if ((__hdrSurface != undefined) && ((surface_get_width(__hdrSurface) != _width) || (surface_get_height(__hdrSurface) != _height)))
        {
            surface_free(__hdrSurface);
            __hdrSurface = undefined;
        }
        
        if ((__hdrSurface == undefined) || !surface_exists(__hdrSurface))
        {
            __hdrSurface = surface_create(_width, _height, surface_rgba16float);
            
            surface_set_target(__hdrSurface);
            draw_clear(c_black);
            surface_reset_target();
        }
        
        return __hdrSurface;
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
            __surface = surface_create(surfaceWidth, surfaceHeight, hdr? surface_rgba16float : surface_rgba8unorm);
            
            surface_set_target(__surface);
            draw_clear_alpha(c_black, 1.0);
            surface_reset_target();
        }
        
        return __surface;
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
        __FreeHDRSurface();
        
        __freed = true;
    }
    
    static GetLightValue = function(_worldX, _worldY, _cameraL, _cameraT, _cameraW, _cameraH)
    {
        var _surface = GetSurface();
        var _x = (_worldX - _cameraL) * (surface_get_width( _surface) / _cameraW);
        var _y = (_worldY - _cameraT) * (surface_get_height(_surface) / _cameraH);
        
        var _result = surface_getpixel_ext(_surface, _x, _y);
        if (not is_array(_result))
        {
            var _colour = _result;
        }
        else
        {
            _result[0] *= hdrExposure;
            _result[1] *= hdrExposure;
            _result[2] *= hdrExposure;
            _result[3]  = clamp(_result[3], 0, 1); //Clamp the alpha channel
            
            static _funcLuminance = function(_red, _green, _blue)
            {
                return 0.2126*_red + 0.7152*_green + 0.0722*_blue;
            }
            
            if (hdrTonemap == BULB_TONEMAP_REINHARD)
            {
                var _luminance    = _funcLuminance(_result[0], _result[1], _result[2]);
                var _luminanceNew = _luminance / (1 + _luminance);
                
                _result[0] *= _luminanceNew / _luminance;
                _result[1] *= _luminanceNew / _luminance;
                _result[2] *= _luminanceNew / _luminance;
            }
            else if (hdrTonemap == BULB_TONEMAP_REINHARD_EXTENDED)
            {
                var _luminance    = _funcLuminance(_result[0], _result[1], _result[2]);
                var _luminanceNew = _luminance * (1.0 + (_luminance / (4*4))) / (1 + _luminance);
                
                _result[0] *= _luminanceNew / _luminance;
                _result[1] *= _luminanceNew / _luminance;
                _result[2] *= _luminanceNew / _luminance;
            }
            else if (hdrTonemap == BULB_TONEMAP_ACES)
            {
                var _r = _result[0];
                var _g = _result[1];
                var _b = _result[2];
                
                _result[0] = (_r*(2.51*_r + 0.03)) / (_r*(2.43*_r + 0.59) + 0.14);
                _result[1] = (_g*(2.51*_g + 0.03)) / (_g*(2.43*_g + 0.59) + 0.14);
                _result[2] = (_b*(2.51*_b + 0.03)) / (_b*(2.43*_b + 0.59) + 0.14);
            }
            
            _result[0] = 255*clamp(power(_result[0], 1/2.2), 0, 1);
            _result[1] = 255*clamp(power(_result[1], 1/2.2), 0, 1);
            _result[2] = 255*clamp(power(_result[2], 1/2.2), 0, 1);
            _result[3] = 255*clamp(, 0, 1);
            
            var _colour = (_result[3] << 24) | (_result[2] << 16) | (_result[1] << 8) | _result[0];
        }
        
        return _colour;
    }
    
    static GetLightValueFromCamera = function(_worldX, _worldY, _camera)
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
        
        return GetLightValue(_worldX, _worldY, _cameraLeft, _cameraTop,  _cameraViewWidth, _cameraViewHeight);
    }
    
    #endregion
    
    static __FreeVertexBuffers = function()
    {
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
    
    static __FreeHDRSurface = function()
    {
        if ((__hdrSurface != undefined) && surface_exists(__hdrSurface))
        {
            surface_free(__hdrSurface);
            __hdrSurface = undefined;
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
        
        //One-time construction of the static occluder geometry
        if (__staticVBuffer == undefined)
        {
            //Create a new vertex buffer
            __staticVBuffer = vertex_create_buffer();
            var _staticVBuffer = __staticVBuffer;
            
            //Add static shadow caster vertices to the relevant vertex buffer
            if (soft)
            {
                vertex_begin(__staticVBuffer, global.__bulbFormat3DNormalTex);
                
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
                vertex_begin(__staticVBuffer, global.__bulbFormat3DNormal);
                
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
        if (soft)
        {
            vertex_begin(_dynamicVBuffer, global.__bulbFormat3DNormalTex);
            
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
            vertex_begin(_dynamicVBuffer, global.__bulbFormat3DNormal);
            
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
    
    static __AccumulateLights = function(_cameraL, _cameraT, _cameraR, _cameraB, _cameraCX, _cameraCY, _cameraW, _cameraH)
    {
        if (__freed) return undefined;
        
        __AccumulateAmbienceSprite(_cameraL, _cameraT, _cameraR, _cameraB);
        
        var _normalCoeff = selfLighting? -1 : 1;
        
        //Iterate over all non-deferred lights...
        if (soft)
        {
            __AccumulateSoftLights(_cameraL, _cameraT, _cameraR, _cameraB, _cameraCX, _cameraCY, _cameraW, _cameraH, _normalCoeff);
        }
        else
        {
            __AccumulateHardLights(_cameraL, _cameraT, _cameraR, _cameraB, _cameraCX, _cameraCY, _cameraW, _cameraH, _normalCoeff);
        }
        
        shader_reset();
        
        __AccumulateShadowOverlay(_cameraL, _cameraT, _cameraR, _cameraB);
        __AccumulateLightOverlay(_cameraL, _cameraT, _cameraR, _cameraB);
        
        //Restore default behaviour
        gpu_set_colorwriteenable(true, true, true, true);
        gpu_set_blendmode(bm_normal);
    }
    
    static __AccumulateAmbienceSprite = function(_cameraL, _cameraT, _cameraR, _cameraB)
    {
        //Now draw shadow overlay sprites, if we have any
        var _size = array_length(__ambienceSpriteArray);
        if (_size > 0)
        {
            gpu_set_colorwriteenable(true, true, true, false);
            
            var _i = 0;
            repeat(_size)
            {
                var _weak = __ambienceSpriteArray[_i];
                if (!weak_ref_alive(_weak) || _weak.ref.__destroyed)
                {
                    array_delete(__ambienceSpriteArray, _i, 1);
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
                                draw_sprite_ext(sprite, image, x, y, xscale, yscale, angle, blend, alpha);
                            }
                        }
                    }
                    
                    ++_i;
                }
            }
            
            gpu_set_colorwriteenable(true, true, true, true);
        }
    }
    
    static __AccumulateShadowOverlay = function(_cameraL, _cameraT, _cameraR, _cameraB)
    {
        //Now draw shadow overlay sprites, if we have any
        var _size = array_length(__shadowOverlayArray);
        if (_size > 0)
        {
            //Leverage the fog system to force the colour of the sprites we draw (alpha channel passes through)
            gpu_set_fog(true, ambientColor, 0, 0);
            
            //Don't touch the alpha channel
            gpu_set_colorwriteenable(true, true, true, false);
            
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
                                draw_sprite_ext(sprite, image, x, y, xscale, yscale, angle, c_white, alpha);
                            }
                        }
                    }
                    
                    ++_i;
                }
            }
            
            //Reset render state
            gpu_set_fog(false, c_white, 0, 0);
            gpu_set_colorwriteenable(true, true, true, true);
        }
    }
    
    static __AccumulateLightOverlay = function(_cameraL, _cameraT, _cameraR, _cameraB)
    {
        //Finally, draw light overlay sprites too
        //We use the overarching blend mode for the renderer
        gpu_set_blendmode(bm_add);
        
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
                            draw_sprite_ext(sprite, image, x, y, xscale, yscale, angle, blend, alpha);
                        }
                    }
                }
                
                ++_i;
            }
        }
        
        //Reset render state
        gpu_set_fog(false, c_white, 0, 0);
        gpu_set_colorwriteenable(true, true, true, true);
    }
    
    #endregion
    
    #region Accumulate soft lights
    
    static __AccumulateSoftLights = function(_cameraL, _cameraT, _cameraR, _cameraB, _cameraCX, _cameraCY, _cameraW, _cameraH, _normalCoeff)
    {
        if (__freed) return undefined;
        
        static _u_vLight                = shader_get_uniform(__shdBulbSoftShadows,         "u_vLight"      );
        static _sunlight_u_vLightVector = shader_get_uniform(__shdBulbSoftShadowsSunlight, "u_vLightVector");
        
        var _staticVBuffer  = __staticVBuffer;
        var _dynamicVBuffer = __dynamicVBuffer;
        
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
                                //Only write into the alpha channel
                                gpu_set_colorwriteenable(false, false, false, true);
                                
                                //Clear the alpha channel for the light's visual area
                                gpu_set_blendmode_ext(bm_one, bm_zero);
                                draw_sprite_ext(sprite, image,
                                                x, y,
                                                xscale, yscale, angle,
                                                c_black, alpha);
                                
                                //Cut out shadows in the alpha channel
                                gpu_set_blendmode(bm_subtract);
                                
                                shader_set(__shdBulbSoftShadows);
                                shader_set_uniform_f(_u_vLight, x, y, penumbraSize);
                                vertex_submit(_staticVBuffer,  pr_trianglelist, -1);
                                vertex_submit(_dynamicVBuffer, pr_trianglelist, -1);
                                
                                //Set the light sprite to borrowing the alpha channel already on the surface
                                gpu_set_colorwriteenable(true, true, true, false);
                                gpu_set_blendmode_ext(bm_dest_alpha, bm_one);
                                
                                //Draw light sprite
                                shader_reset();
                                draw_sprite_ext(sprite, image,
                                                x, y,
                                                xscale, yscale, angle,
                                                blend, 1);
                            }
                            else
                            {
                                //No shadows - draw the light sprite normally
                                gpu_set_blendmode(bm_add);
                                draw_sprite_ext(sprite, image,
                                                x, y,
                                                xscale, yscale, angle,
                                                blend, alpha);
                            }
                        }
                    }
                }
                
                ++_i;
            }
        }
        
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
                        //Only write into the alpha channel
                        gpu_set_colorwriteenable(false, false, false, true);
                        
                        //Clear the alpha channel for the light's visual area
                        gpu_set_blendmode_ext(bm_one, bm_zero);
                        draw_sprite_ext(__sprBulbPixel, 0, _cameraL, _cameraT, _cameraW+1, _cameraH+1, 0, c_black, alpha);
                        
                        //Cut out shadows in the alpha channel
                        gpu_set_blendmode(bm_subtract);
                        
                        shader_set(__shdBulbSoftShadowsSunlight);
                        shader_set_uniform_f(_sunlight_u_vLightVector, dcos(angle), -dsin(angle), penumbraSize);
                        vertex_submit(_staticVBuffer,  pr_trianglelist, -1);
                        vertex_submit(_dynamicVBuffer, pr_trianglelist, -1);
                        
                        //Set the light sprite to borrowing the alpha channel already on the surface
                        gpu_set_colorwriteenable(true, true, true, false);
                        gpu_set_blendmode_ext(bm_dest_alpha, bm_one);
                        
                        //Draw light sprite
                        shader_reset();
                        draw_sprite_ext(__sprBulbPixel, 0, _cameraL, _cameraT, _cameraW+1, _cameraH+1, 0, blend, 1);
                    }
                }
                
                ++_i;
            }
        }
        
        gpu_set_blendmode(bm_normal);
    }
    
    #endregion
    
    #region Accumulate hard lights
    
    static __AccumulateHardLights = function(_cameraL, _cameraT, _cameraR, _cameraB, _cameraCX, _cameraCY, _cameraW, _cameraH, _normalCoeff)
    {
        if (__freed) return undefined;
        
        static _u_vLight                = shader_get_uniform(__shdBulbHardShadows,         "u_vLight"      );
        static _u_fNormalCoeff          = shader_get_uniform(__shdBulbHardShadows,         "u_fNormalCoeff");
        static _sunlight_u_vLightVector = shader_get_uniform(__shdBulbHardShadowsSunlight, "u_vLightVector");
        static _sunlight_u_fNormalCoeff = shader_get_uniform(__shdBulbHardShadowsSunlight, "u_fNormalCoeff");
        
        var _staticVBuffer  = __staticVBuffer;
        var _dynamicVBuffer = __dynamicVBuffer;
        
        //bm_max requires some trickery with alpha to get good-looking results
        //Determine the blend mode and "default" shader accordingly
        var _resetShader = __shdBulbPassThrough;
        gpu_set_blendmode(bm_add);
        
        //Set up the coefficient to flip normals
        //We use this to control self-lighting
        shader_set(__shdBulbHardShadows);
        shader_set_uniform_f(_u_fNormalCoeff, _normalCoeff);
        
        //Also do the same for our sunlight shader, provided we have any sunlight sources
        if (array_length(__sunlightArray) > 0)
        {
            shader_set(__shdBulbHardShadowsSunlight);
            shader_set_uniform_f(_sunlight_u_fNormalCoeff, _normalCoeff);
        }
        
        //Set our default shader
        shader_set(_resetShader);
        
        //And switch on z-testing. We'll use z-testing for stenciling
        gpu_set_ztestenable(true);
        gpu_set_zwriteenable(true);
        gpu_set_zfunc(cmpfunc_lessequal);
        
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
                                //Turn off all RGBA writing, leaving only z-writing
                                gpu_set_colorwriteenable(false, false, false, false);
                                
                                //Guarantee that we're going to write to the z-buffer with the next operations
                                gpu_set_zfunc(cmpfunc_always);
                                
                                //Reset z-buffer
                                draw_sprite_ext(sprite, image,
                                                x, y,
                                                xscale, yscale, angle,
                                                c_black, 1);
                                
                                //Stencil out shadow areas
                                shader_set(__shdBulbHardShadows);
                                shader_set_uniform_f(_u_vLight, x, y);
                                vertex_submit(_staticVBuffer,  pr_trianglelist, -1);
                                vertex_submit(_dynamicVBuffer, pr_trianglelist, -1);
                                
                                //Swap to drawing RGB data (no alpha to make the output surface tidier)
                                gpu_set_colorwriteenable(true, true, true, false);
                                gpu_set_zfunc(cmpfunc_lessequal);
                                
                                //Reset shader and draw the light itself, but "behind" the shadows
                                shader_set(_resetShader);                      
                                draw_sprite_ext(sprite, image,
                                                x, y,
                                                xscale, yscale, angle,
                                                blend, alpha);
                            }
                            else
                            {
                                //Ensure any previous changes to the z-buffer don't leak across
                                gpu_set_colorwriteenable(true, true, true, false);
                                gpu_set_zfunc(cmpfunc_always);
                                
                                //Just draw the sprite, no fancy stuff here
                                draw_sprite_ext(sprite, image,
                                                x, y,
                                                xscale, yscale, angle,
                                                blend, alpha);
                            }
                        }
                    }
                }
                
                ++_i;
            }
        }
        
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
                        //Turn off all RGBA writing, leaving only z-writing
                        gpu_set_colorwriteenable(false, false, false, false);
                        
                        //Guarantee that we're going to write to the z-buffer with the next operations
                        gpu_set_zfunc(cmpfunc_always);
                        
                        //Full surface clear of the z-buffer
                        draw_sprite_ext(__sprBulbPixel, 0, _cameraL, _cameraT, _cameraW+1, _cameraH+1, 0, c_black, 0);
                        
                        //Stencil out shadow areas
                        shader_set(__shdBulbHardShadowsSunlight);
                        shader_set_uniform_f(_sunlight_u_vLightVector, dcos(angle), -dsin(angle));
                        vertex_submit(_staticVBuffer,  pr_trianglelist, -1);
                        vertex_submit(_dynamicVBuffer, pr_trianglelist, -1);
                        
                        //Swap to drawing RGB data (no alpha to make the output surface tidier)
                        gpu_set_colorwriteenable(true, true, true, false);
                        gpu_set_zfunc(cmpfunc_lessequal);
                        
                        //Reset shader and draw the light itself, but "behind" the shadows
                        shader_set(_resetShader);
                        draw_sprite_ext(__sprBulbPixel, 0, _cameraL, _cameraT, _cameraW+1, _cameraH+1, 0, blend, alpha);
                    }
                }
                
                ++_i;
            }
        }
        
        shader_reset();
        gpu_set_zfunc(cmpfunc_lessequal);
        gpu_set_blendmode(bm_normal);
        gpu_set_ztestenable(false);
        gpu_set_zwriteenable(false);
    }
    
    #endregion
}