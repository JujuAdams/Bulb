// Full list of variables:
// 
// `.ambientColor`        | `c_black`           | Baseline ambient light color
// `.ambientInGammaSpace` | `false`             | Whether the above is in gamma space (`true`) or linear space {`false`)
// `.smooth`              | `true`              | Whether to use texture filtering (bilinear interpolation) where possible
// `.soft`                | `true`              | Whether to use soft shadows
// `.selfLighting`        | `false`             | Whether to allow light to enter but not escape occluders. Hard shadow mode only
// `.exposure`            | `1.0`               | Exposure for the entire lighting render. Should usually be left at `1.0` when not in HDR mode
// `.ldrTonemap`          | `BULB_TONEMAP_CLAMP`| Tonemap to use when not in HDR mode. Should usually be left at `BULB_TONEMAP_CLAMP`
// `.hdr`                 | `false`             | Whether to use HDR rendering or not. HDR surface is 16-bit
// `.hdrTonemap`          | `BULB_TONEMAP_HBD`  | Tonemap to use when in HDR mode
// `.hdrBloomIntensity`   | `0`                 | Intensity of the bloom effect
// `.hdrBloomIterations`  | `3`                 | Number of Kawase blur iterations to apply to the bloom
// `.hdrBloomThesholdMin` | `0.6`               | Lower threshold for bloom cut-off
// `.hdrBloomThesholdMax` | `0.8`               | Upper threshold for bloom cut-off
// `.normalMap`           | Config macro        | Whether normal mapping should be used. Defaults to `BULB_DEFAULT_USE_NORMAL_MAP`
// 
// Full list of methods:
// 
// `.SetSurfaceDimensionsFromCamera(camera)`
// `.SetSurfaceDimensions(width, height)`
// `.UpdateFromCamera(camera)`
// `.Update(left, top, width, height)`
// `.DrawLitSurface(surface, x, y, width, height, [textureFiltering], [alphaBlend])`
// `.Free()`
// `.GetTonemap()`
// `.RefreshStaticOccluders()`
// `.GetNormalMapSurface()
// `.DrawNormalMapDebug()`

function BulbRenderer() constructor
{
    static _system = __BulbSystem();
    
    static _vformat3DNormal = (function()
    {
        vertex_format_begin();
        vertex_format_add_position_3d();
        vertex_format_add_normal();
        return vertex_format_end();
    })();

    static _vformat3DNormalTex = (function()
    {
        vertex_format_begin();
        vertex_format_add_position_3d();
        vertex_format_add_normal();
        vertex_format_add_texcoord();
        return vertex_format_end();
    })();
    
    //Assign the ambient colour used for the darkest areas of the screen. This can be changed on the fly
    ambientColor = c_black;
    ambientInGammaSpace = false;
    
    //The smoothing mode controls texture filtering both when accumulating lights and when drawing the resulting surface
    smooth = true;
    
    selfLighting = false;
    
    soft = true;
    __oldSoft = undefined;
    
    exposure   = 1;
    ldrTonemap = BULB_TONEMAP_CLAMP;
    
    surfaceWidth  = -1;
    surfaceHeight = -1;
    
    __BulbRendererDefineHDR();
    __BulbRendererDefineNormal();
    __BulbRendererDefineOverlayUnderlay();
    __BulbRendererDefineAccumulateSoft();
    __BulbRendererDefineAccumulateHard();
    __BulbRendererDefineVertexBuffers();
    __BulbRendererDefineLight();
    
    
    
    
    SetSurfaceDimensionsFromCamera = function(_camera)
    {
        var _projMatrix = camera_get_proj_mat(_camera);
        var _width  = round(abs(2/_projMatrix[0]));
        var _height = round(abs(2/_projMatrix[5]));
        
        return SetSurfaceDimensions(_width, _height);
    }
    
    SetSurfaceDimensions = function(_width, _height)
    {
        surfaceWidth  = _width;
        surfaceHeight = _height;
        
        GetLightSurface();
    }
    
    UpdateFromCamera = function(_camera)
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
    
    Update = function(_cameraL, _cameraT, _cameraW, _cameraH)
    {
        static _worldMatrix = [1,0,0,0,   0,1,0,0,   0,0,1,0,   0,0,0,1];
        
        if (surfaceWidth  <= 0) surfaceWidth  = _cameraW;
        if (surfaceHeight <= 0) surfaceHeight = _cameraH;
        
        //Force a regeneration of vertex buffers if we're swapped between hard/soft lights
        if (soft != __oldSoft)
        {
            __oldSoft = soft;
            __FreeVertexBuffers();
        }
        
        //Determine whether we actually want HDR
        var _hdr = (hdr && _system.__hdrAvailable);
        
        //Force regeneration/freeing of surfaces if the HDR state has changed
        if (_hdr != __oldHDR)
        {
            __oldHDR = _hdr;
            
            if (__lightSurface != undefined)
            {
                surface_free(__lightSurface);
                __lightSurface = undefined;
            }
            
            if (not _hdr)
            {
                __FreeHDRSurface();
            }
        }
        
        //Manage bloom surfaces if the number of iterations has changed
        if ((not _hdr) || (hdrBloomIterations != __oldHDRBloomIterations))
        {
            __FreeBloomSurfaces();
        }
        
        //Free up memory if the normal map state has changed
        if ((not normalMap) && __oldNormalMap)
        {
            __FreeNormalMapSurface();
        }
        
        var _cameraR  = _cameraL + _cameraW;
        var _cameraB  = _cameraT + _cameraH;
        var _cameraCX = _cameraL + 0.5*_cameraW;
        var _cameraCY = _cameraT + 0.5*_cameraH;
        
        //Construct our wipe/static/dynamic vertex buffers
        __UpdateVertexBuffers(_cameraL, _cameraT, _cameraR, _cameraB, _cameraW, _cameraH);
        
        //Create accumulating renderer surface
        surface_set_target(GetLightSurface());
        
        gpu_set_cullmode(cull_noculling);
        
        //Really we should use the view matrix for this, but GameMaker's sprite culling is fucked
        //If we use a proper view matrix then renderer sprites are culling, leading to no renderer being drawn
        _worldMatrix[@ 12] = -_cameraL;
        _worldMatrix[@ 13] = -_cameraT;
        matrix_set(matrix_world, _worldMatrix);
        
        //Record the current texture filter state, then set our new filter state
        var _old_tex_filter = gpu_get_tex_filter();
        gpu_set_tex_filter(smooth);
        
        //Clear the light surface with the ambient colour
        draw_clear(__GetAmbientColor());
        
        //If we're not forcing deferred rendering everywhere, update those lights
        __AccumulateLights(_cameraL, _cameraT, _cameraR, _cameraB, _cameraCX, _cameraCY, _cameraW, _cameraH);
        
        //Restore the old filter state
        gpu_set_tex_filter(_old_tex_filter);
        
        surface_reset_target();
        matrix_set(matrix_world, matrix_build_identity());
    }
    
    DrawLitSurface = function(_surface, _x, _y, _width, _height, _textureFiltering = undefined, _alphaBlend = undefined)
    {
        static _u_fIntensity = shader_get_uniform(__shdBulbIntensity, "u_fIntensity");
        static _u_vThreshold = shader_get_uniform(__shdBulbKawaseDownWithThreshold, "u_vThreshold");
        
        var _oldTextureFiltering = gpu_get_tex_filter();
        var _oldAlphaBlend       = gpu_get_blendenable();
        
        var _hdrTonemap = GetTonemap();
        if (_hdrTonemap == BULB_TONEMAP_CLAMP)
        {
            var _shader = __shdBulbTonemapClamp;
        }
        else if (_hdrTonemap == BULB_TONEMAP_REINHARD)
        {
            var _shader = __shdBulbTonemapReinhard;
        }
        else if (_hdrTonemap == BULB_TONEMAP_REINHARD_EXTENDED)
        {
            var _shader = __shdBulbTonemapReinhardExtended;
        }
        else if (_hdrTonemap == BULB_TONEMAP_ACES)
        {
            var _shader = __shdBulbTonemapACES;
        }
        else if (_hdrTonemap == BULB_TONEMAP_UNCHARTED2)
        {
            var _shader = __shdBulbTonemapUncharted2;
        }
        else if (_hdrTonemap == BULB_TONEMAP_UNREAL3)
        {
            var _shader = __shdBulbTonemapUnreal3;
        }
        else if (_hdrTonemap == BULB_TONEMAP_HBD)
        {
            var _shader = __shdBulbTonemapHBD;
        }
        else
        {
            var _shader = __shdBulbTonemapBadGamma;
        }
        
        if (hdr && _system.__hdrAvailable)
        {
            var _surfaceWidth  = surface_get_width( _surface);
            var _surfaceHeight = surface_get_height(_surface);
            
            __GetHDRSurface(_surfaceWidth, _surfaceHeight);
            
            surface_set_target(__hdrSurface);
            draw_clear(c_black);
            surface_reset_target();
            
            gpu_set_colorwriteenable(true, true, true, false);
            
            shader_set(__shdBulbGammaToLinear);
            surface_copy(__hdrSurface, 0, 0, _surface);
            shader_reset();
            
            surface_set_target(__hdrSurface);
            gpu_set_blendmode_ext(bm_zero, bm_src_color);
            shader_set(__shdBulbIntensity);
            
            shader_set_uniform_f(_u_fIntensity, exposure);
            draw_surface_stretched(__lightSurface, 0, 0, _surfaceWidth, _surfaceHeight);
            
            gpu_set_blendmode(bm_normal);
            surface_reset_target();
            shader_reset();
            
            gpu_set_colorwriteenable(true, true, true, true);
            
            if ((hdrBloomIntensity > 0) && (hdrBloomIterations >= 1))
            {
                if (array_length(__bloomSurfaceArray) < hdrBloomIterations)
                {
                    __FreeBloomSurfaces();
                    
                    var _bloomWidth  = _surfaceWidth;
                    var _bloomHeight = _surfaceHeight;
                    
                    var _i = 0;
                    repeat(hdrBloomIterations)
                    {
                        _bloomWidth  = _bloomWidth  div 2;
                        _bloomHeight = _bloomHeight div 2;
                        
                        __bloomSurfaceArray[_i] = surface_create(_bloomWidth, _bloomHeight, surface_rgba16float);
                        
                        ++_i;
                    }
                }
                
                gpu_set_tex_filter(true);
                
                surface_set_target(__bloomSurfaceArray[0]);
                shader_set(__shdBulbKawaseDownWithThreshold);
                shader_set_uniform_f(_u_vThreshold, hdrBloomThesholdMin, hdrBloomThesholdMax);
                shader_set_uniform_f(shader_get_uniform(__shdBulbKawaseDownWithThreshold, "u_vTexel"), texture_get_texel_width(surface_get_texture(__hdrSurface)), texture_get_texel_height(surface_get_texture(__hdrSurface)));
                draw_surface_stretched(__hdrSurface, 0, 0, surface_get_width(__bloomSurfaceArray[0]), surface_get_height(__bloomSurfaceArray[0]));
                shader_reset();
                surface_reset_target();
                
                if (hdrBloomIterations >= 2)
                {
                    var _i = 1;
                    repeat(hdrBloomIterations-1)
                    {
                        surface_set_target(__bloomSurfaceArray[_i]);
                            shader_set(__shdBulbKawaseDown);
                            shader_set_uniform_f(shader_get_uniform(__shdBulbKawaseDown, "u_vTexel"), texture_get_texel_width(surface_get_texture(__bloomSurfaceArray[_i-1])), texture_get_texel_height(surface_get_texture(__bloomSurfaceArray[_i-1])));
                            draw_surface_stretched(__bloomSurfaceArray[_i-1], 0, 0, surface_get_width(__bloomSurfaceArray[_i]), surface_get_height(__bloomSurfaceArray[_i]));
                        surface_reset_target();
                        
                        ++_i;
                    }
                    
                    var _i = hdrBloomIterations-1;
                    repeat(hdrBloomIterations-1)
                    {
                        surface_set_target(__bloomSurfaceArray[_i-1]);
                            shader_set(__shdBulbKawaseUp);
                            shader_set_uniform_f(shader_get_uniform(__shdBulbKawaseUp, "u_vTexel"), texture_get_texel_width(surface_get_texture(__bloomSurfaceArray[_i])), texture_get_texel_height(surface_get_texture(__bloomSurfaceArray[_i])));
                            draw_surface_stretched(__bloomSurfaceArray[_i], 0, 0, surface_get_width(__bloomSurfaceArray[_i-1]), surface_get_height(__bloomSurfaceArray[_i-1]));
                        surface_reset_target();
                        
                        --_i;
                    }
                }
                
                surface_set_target(__hdrSurface);
                
                    gpu_set_blendmode(bm_add);
                    shader_set(__shdBulbIntensity);
                    shader_set_uniform_f(_u_fIntensity, hdrBloomIntensity);
                    draw_surface_stretched_ext(__bloomSurfaceArray[0], 0, 0, _surfaceWidth, _surfaceHeight, c_white, 1);
                    
                    gpu_set_blendmode(bm_normal);
                    shader_reset();
                
                surface_reset_target();
            }
            
            shader_set(_shader);
            shader_set_uniform_f(shader_get_uniform(_shader, "u_fExposure"), 1);
            if (_textureFiltering != undefined) gpu_set_tex_filter(_textureFiltering);
            if (_alphaBlend != undefined) gpu_set_blendenable(_alphaBlend);
            draw_surface_stretched(__hdrSurface, _x, _y, _width, _height);
            shader_reset();
        }
        else
        {
            draw_surface_stretched(_surface, _x, _y, _width, _height);
            
            if ((__lightSurface != undefined) && surface_exists(__lightSurface))
            {
                gpu_set_tex_filter(smooth);
                gpu_set_blendenable(true);
                
                gpu_set_blendmode_ext(bm_dest_color, bm_zero);
                gpu_set_colorwriteenable(true, true, true, false);
                
                shader_set(_shader);
                shader_set_uniform_f(shader_get_uniform(_shader, "u_fExposure"), exposure);
                draw_surface_stretched(__lightSurface, _x, _y, _width, _height);
                shader_reset();
                
                gpu_set_blendmode(bm_normal);
                gpu_set_colorwriteenable(true, true, true, true);
            }
        }
        
        gpu_set_tex_filter(_oldTextureFiltering);
        gpu_set_blendenable(_oldAlphaBlend);
    }
    
    Free = function()
    {
        __FreeVertexBuffers();
        __FreeLightSurface();
        __FreeHDRSurface();
        __FreeBloomSurfaces();
        __FreeNormalMapSurface();
        
        var _nullFunc = function() {}
        
        //__BulbRendererDefineHDR()
        __GetHDRSurface     = _nullFunc;
        __FreeHDRSurface    = _nullFunc;
        __FreeBloomSurfaces = _nullFunc;
        
        //__BulbRendererDefineNormal()
        GetNormalMapSurface    = _nullFunc;
        DrawNormalMapDebug     = _nullFunc;
        __FreeNormalMapSurface = _nullFunc;
        
        //__BulbRendererDefineOverlayUnderlay()
        __AccumulateAmbienceSprite = _nullFunc;
        __AccumulateShadowOverlay  = _nullFunc;
        __AccumulateLightOverlay   = _nullFunc;
        
        //__BulbRendererDefineAccumulateSoft()
        __AccumulateSoftLights = _nullFunc;
        
        //__BulbRendererDefineAccumulateHard()
        __AccumulateHardLights = _nullFunc;
        
        //__BulbRendererDefineVertexBuffers()
        RefreshStaticOccluders = _nullFunc;
        __FreeVertexBuffers    = _nullFunc;
        __UpdateVertexBuffers  = _nullFunc;
        
        //__BulbRendererDefineLight()
        GetLightSurface         = _nullFunc;
        __FreeLightSurface      = _nullFunc;
        GetLightValue           = _nullFunc;
        GetLightValueFromCamera = _nullFunc;
        __AccumulateLights      = _nullFunc;
    }
    
    GetTonemap = function()
    {
        return (hdr && _system.__hdrAvailable)? hdrTonemap : ldrTonemap;
    }
    
    __GetAmbientColor = function()
    {
        if (GetTonemap() == BULB_TONEMAP_BAD_GAMMA)
        {
            if (ambientInGammaSpace)
            {
                return ambientColor;
            }
            else
            {
                return make_color_rgb(255*power(color_get_red(  ambientColor)/255, 1/BULB_GAMMA),
                                      255*power(color_get_green(ambientColor)/255, 1/BULB_GAMMA),
                                      255*power(color_get_blue( ambientColor)/255, 1/BULB_GAMMA));
            }
        }
        else
        {
            if (ambientInGammaSpace)
            {
                return make_color_rgb(255*power(color_get_red(  ambientColor)/255, BULB_GAMMA),
                                      255*power(color_get_green(ambientColor)/255, BULB_GAMMA),
                                      255*power(color_get_blue( ambientColor)/255, BULB_GAMMA));
            }
            else
            {
                return ambientColor;
            }
        }
    }
}