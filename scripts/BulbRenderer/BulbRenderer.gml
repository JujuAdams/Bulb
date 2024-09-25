/// Constructor. Creates a Bulb renderer struct that is responsible for the final renderering of
/// lights in your game.
/// 
/// @param [camera]
/// 
/// Full list of variables:
/// 
/// `.ambientColor`         | `c_black`           | Baseline ambient light color
/// `.ambientInGammaSpace`  | `false`             | Whether the above is in gamma space (`true`) or linear space {`false`)
/// `.smooth`               | `true`              | Whether to use texture filtering (bilinear interpolation) where possible
/// `.soft`                 | `true`              | Whether to use soft shadows
/// `.selfLighting`         | `false`             | Whether to allow light to enter but not escape occluders. Hard shadow mode only
/// `.exposure`             | `1.0`               | Exposure for the entire lighting render. Should usually be left at `1.0` when not in HDR mode
/// `.ldrTonemap`           | `BULB_TONEMAP_NONE` | Tonemap to use when not in HDR mode. Should usually be left at `BULB_TONEMAP_NONE`
/// `.hdr`                  | `false`             | Whether to use HDR rendering or not. HDR surface is 16-bit
/// `.hdrTonemap`           | `BULB_TONEMAP_HBD`  | Tonemap to use when in HDR mode
/// `.hdrBloomIntensity`    | `0`                 | Intensity of the bloom effect
/// `.hdrBloomIterations`   | `3`                 | Number of Kawase blur iterations to apply to the bloom
/// `.hdrBloomThresholdMin` | `0.6`               | Lower threshold for bloom cut-off
/// `.hdrBloomThresholdMax` | `0.8`               | Upper threshold for bloom cut-off
/// `.normalMap`            | Config macro        | Whether normal mapping should be used. Defaults to `BULB_DEFAULT_USE_NORMAL_MAP`
/// 
/// Full list of methods:
/// 
/// `.Free()`
/// `.SetCamera(camera)`
/// `.GetCamera()`
/// `.SetSurfaceDimensions(width, height)`
/// `.GetSurfaceDimensions()`
/// `.Update()`
/// `.GetOutputSurface(surface)`
/// `.DrawLitSurface(surface, x, y, width, height, [textureFiltering], [alphaBlend])`
/// `.GetTonemap()`
/// `.GetLightSurface()`
/// `.GetLightValue(x, y)`
/// `.GetNormalMapSurface()
/// `.DrawNormalMapDebug(x, y, width, height)`
/// `.RefreshStaticOccluders()`

function BulbRenderer(_camera) constructor
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
    
    
    
    SetCamera = function(_camera)
    {
        if (__cameraImplicit)
        {
            camera_destroy(__camera);
        }
        
        if (_camera != undefined)
        {
            __camera         = _camera;
            __cameraImplicit = false;
        }
        else
        {
            __camera         = camera_create_view(0, 0, room_width, room_height, 0,   noone, 0, 0, 0, 0);
            __cameraImplicit = true;
        }
        
        //Set the lighting surface dimensions from the camera
        var _projMatrix = camera_get_proj_mat(__camera);
        var _width  = round(abs(2/_projMatrix[0]));
        var _height = round(abs(2/_projMatrix[5]));
        SetSurfaceDimensions(_width, _height);
    }
    
    GetCamera = function()
    {
        return __camera;
    }
    
    SetSurfaceDimensions = function(_width, _height)
    {
        __surfaceWidth  = _width;
        __surfaceHeight = _height;
        
        GetLightSurface();
    }
    
    GetSurfaceDimensions = function()
    {
        static _result = {};
        
        _result.width  = __surfaceWidth;
        _result.height = __surfaceHeight;
        
        return _result;
    }
    
    Update = function()
    {
        //Deploy PROPER MATHS in case the dev is using matrices
        
        var _viewMatrix = camera_get_view_mat(__camera);
        var _projMatrix = camera_get_proj_mat(__camera);
        
        var _cameraCos =  _viewMatrix[ 0];
        var _cameraSin =  _viewMatrix[ 1];
        var _matrixX   = -_viewMatrix[12];
        var _matrixY   = -_viewMatrix[13];
        
        var _cameraCX =  _matrixX*_cameraCos + _matrixY*_cameraSin;
        var _cameraCY = -_matrixX*_cameraSin + _matrixY*_cameraCos;
        var _cameraW  = round(abs(2/_projMatrix[0]));
        var _cameraH  = round(abs(2/_projMatrix[5]));
        
        var _rotatedW = _cameraW*abs(_cameraCos) + _cameraH*abs(_cameraSin);
        var _rotatedH = _cameraW*abs(_cameraSin) + _cameraH*abs(_cameraCos);
        
        var _boundaryL = _cameraCX - _rotatedW/2;
        var _boundaryT = _cameraCY - _rotatedH/2;
        var _boundaryR = _cameraCX + _rotatedW/2;
        var _boundaryB = _cameraCY + _rotatedH/2;
        
        var _boundaryExpandedL = _boundaryL - BULB_DYNAMIC_OCCLUDER_RANGE;
        var _boundaryExpandedT = _boundaryT - BULB_DYNAMIC_OCCLUDER_RANGE;
        var _boundaryExpandedR = _boundaryR + BULB_DYNAMIC_OCCLUDER_RANGE;
        var _boundaryExpandedB = _boundaryB + BULB_DYNAMIC_OCCLUDER_RANGE;
        
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
                __FreeOutputSurface();
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
        
        //Construct our wipe/static/dynamic vertex buffers
        __UpdateVertexBuffers(_boundaryExpandedL, _boundaryExpandedT, _boundaryExpandedR, _boundaryExpandedB);
        
        //Create accumulating renderer surface
        surface_set_target(GetLightSurface());
        
        //Set the view/projection matrices
        camera_apply(__camera);
        
        //Set up some GPU state
        var _oldNoCulling = gpu_get_cullmode();
        var _oldTexFilter = gpu_get_tex_filter();
        gpu_set_cullmode(cull_noculling);
        gpu_set_tex_filter(smooth);
        
        //Clear the light surface with the ambient colour
        draw_clear(__GetAmbientColor());
        
        //Accumulate lights and shadows onto the lighting surface
        __AccumulateAmbienceSprite(_boundaryL, _boundaryT, _boundaryR, _boundaryB);
        
        if (soft)
        {
            __AccumulateSoftLights(_boundaryL, _boundaryT, _boundaryR, _boundaryB, _cameraCX, _cameraCY, _cameraW, _cameraH, _cameraCos, _cameraSin, selfLighting? -1 : 1);
        }
        else
        {
            __AccumulateHardLights(_boundaryL, _boundaryT, _boundaryR, _boundaryB, _cameraCX, _cameraCY, _cameraW, _cameraH, _cameraCos, _cameraSin, selfLighting? -1 : 1);
        }
        
        __AccumulateShadowOverlay(_boundaryL, _boundaryT, _boundaryR, _boundaryB);
        __AccumulateLightOverlay(_boundaryL, _boundaryT, _boundaryR, _boundaryB);
        
        //Restore default behaviour
        gpu_set_colorwriteenable(true, true, true, true);
        gpu_set_blendmode(bm_normal);
        gpu_set_cullmode(_oldNoCulling);
        gpu_set_tex_filter(_oldTexFilter);
        
        surface_reset_target();
    }
    
    __GetTonemapShader = function()
    {
        var _hdrTonemap = GetTonemap();
        if (_hdrTonemap == BULB_TONEMAP_NONE)
        {
            return __shdBulbTonemapNone;
        }
        else if (_hdrTonemap == BULB_TONEMAP_CLAMP)
        {
            return __shdBulbTonemapClamp;
        }
        else if (_hdrTonemap == BULB_TONEMAP_REINHARD)
        {
            return __shdBulbTonemapReinhard;
        }
        else if (_hdrTonemap == BULB_TONEMAP_REINHARD_EXTENDED)
        {
            return __shdBulbTonemapReinhardExtended;
        }
        else if (_hdrTonemap == BULB_TONEMAP_ACES)
        {
            return __shdBulbTonemapACES;
        }
        else if (_hdrTonemap == BULB_TONEMAP_UNCHARTED2)
        {
            return __shdBulbTonemapUncharted2;
        }
        else if (_hdrTonemap == BULB_TONEMAP_UNREAL3)
        {
            return __shdBulbTonemapUnreal3;
        }
        else if (_hdrTonemap == BULB_TONEMAP_HBD)
        {
            return __shdBulbTonemapHBD;
        }
        else
        {
            return __shdBulbTonemapBadGamma;
        }
    }
    
    GetOutputSurface = function(_surface)
    {
        var _surfaceWidth  = surface_get_width( _surface);
        var _surfaceHeight = surface_get_height(_surface);
        __GetOutputSurface(_surfaceWidth, _surfaceHeight);
        
        surface_set_target(__outputSurface);
        DrawLitSurface(_surface, 0, 0, _surfaceWidth, _surfaceHeight, false, false);
        surface_reset_target();
        
        return __outputSurface;
    }
    
    DrawLitSurface = function(_surface, _x, _y, _width, _height, _textureFiltering = undefined, _alphaBlend = undefined)
    {
        if (surface_get_target() == _surface)
        {
            __BulbError("Cannot call .DrawLitSurface() when the destination surface and drawn surface are the same\nIf you are drawing the application surface, use a Post-Draw event or GUI draw event");
        }
        
        var _oldTextureFiltering = gpu_get_tex_filter();
        var _oldAlphaBlend       = gpu_get_blendenable();
        
        if (_textureFiltering != undefined) gpu_set_tex_filter(_textureFiltering);
        if (_alphaBlend != undefined) gpu_set_blendenable(_alphaBlend);
        
        if ((__lightSurface != undefined) && surface_exists(__lightSurface))
        {
            if (hdr && _system.__hdrAvailable
            && (hdrBloomIntensity > 0) && (hdrBloomIterations >= 1)
            && (__lightSurface != undefined) && surface_exists(__lightSurface))
            {
                __KawaseBloom(__lightSurface, 1/max(0.0001, exposure));
            }
            
            var _shader = __GetTonemapShader();
            var _exposureUniform = shader_get_uniform(_shader, "u_fExposure");
            var _sampler = shader_get_sampler_index(_shader, "u_sLightMap");
            
            shader_set(_shader);
            shader_set_uniform_f(_exposureUniform, exposure);
            texture_set_stage(_sampler, surface_get_texture(__lightSurface));
            gpu_set_tex_filter_ext(_sampler, smooth);
            draw_surface_stretched(_surface, _x, _y, _width, _height);
            shader_reset();
        }
        else
        {
            draw_surface_stretched(_surface, _x, _y, _width, _height);
        }
        
        gpu_set_tex_filter(_oldTextureFiltering);
        gpu_set_blendenable(_oldAlphaBlend);
    }
    
    __KawaseBloom = function(_surface, _thresholdCoeff)
    {
        static _u_fIntensity = shader_get_uniform(__shdBulbIntensity, "u_fIntensity");
        static _u_vThreshold = shader_get_uniform(__shdBulbKawaseDownWithThreshold, "u_vThreshold");
        
        var _surfaceWidth  = surface_get_width( _surface);
        var _surfaceHeight = surface_get_height(_surface);
        
        var _bloomSurfaceArray = __bloomSurfaceArray;
        
        //Create new bloom surfaces on demand
        if (array_length(_bloomSurfaceArray) < hdrBloomIterations-1)
        {
            __FreeBloomSurfaces();
            
            var _bloomWidth  = _surfaceWidth;
            var _bloomHeight = _surfaceHeight;
            
            //Work around compile error in LTS
            var _surface_create = surface_create;
            
            var _i = 0;
            repeat(hdrBloomIterations)
            {
                _bloomWidth  = _bloomWidth  div 2;
                _bloomHeight = _bloomHeight div 2;
                _bloomSurfaceArray[_i] = _surface_create(_bloomWidth, _bloomHeight, surface_rgba16float);
                
                ++_i;
            }
        }
        
        //Perform Kawase blur
        var _oldTextureFiltering = gpu_get_tex_filter();
        var _oldAlphaBlend       = gpu_get_blendenable();
        
        gpu_set_tex_filter(true);
        gpu_set_blendenable(false);
        
        surface_set_target(_bloomSurfaceArray[0]);
        shader_set(__shdBulbKawaseDownWithThreshold);
        shader_set_uniform_f(_u_vThreshold, hdrBloomThresholdMin*_thresholdCoeff, hdrBloomThresholdMax*_thresholdCoeff);
        shader_set_uniform_f(shader_get_uniform(__shdBulbKawaseDownWithThreshold, "u_vTexel"), texture_get_texel_width(surface_get_texture(_surface)), texture_get_texel_height(surface_get_texture(_surface)));
        draw_surface_stretched(_surface, 0, 0, surface_get_width(_bloomSurfaceArray[0]), surface_get_height(_bloomSurfaceArray[0]));
        shader_reset();
        surface_reset_target();
        
        if (hdrBloomIterations >= 2)
        {
            var _i = 1;
            repeat(hdrBloomIterations-1)
            {
                surface_set_target(_bloomSurfaceArray[_i]);
                    shader_set(__shdBulbKawaseDown);
                    shader_set_uniform_f(shader_get_uniform(__shdBulbKawaseDown, "u_vTexel"), texture_get_texel_width(surface_get_texture(_bloomSurfaceArray[_i-1])), texture_get_texel_height(surface_get_texture(_bloomSurfaceArray[_i-1])));
                    draw_surface_stretched(_bloomSurfaceArray[_i-1], 0, 0, surface_get_width(_bloomSurfaceArray[_i]), surface_get_height(_bloomSurfaceArray[_i]));
                surface_reset_target();
                    
                ++_i;
            }
            
            var _i = hdrBloomIterations-1;
            repeat(hdrBloomIterations-1)
            {
                surface_set_target(_bloomSurfaceArray[_i-1]);
                    shader_set(__shdBulbKawaseUp);
                    shader_set_uniform_f(shader_get_uniform(__shdBulbKawaseUp, "u_vTexel"), texture_get_texel_width(surface_get_texture(_bloomSurfaceArray[_i])), texture_get_texel_height(surface_get_texture(_bloomSurfaceArray[_i])));
                    draw_surface_stretched(_bloomSurfaceArray[_i], 0, 0, surface_get_width(_bloomSurfaceArray[_i-1]), surface_get_height(_bloomSurfaceArray[_i-1]));
                surface_reset_target();
                
                --_i;
            }
        }
            
        gpu_set_blendenable(true);
        
        surface_set_target(_surface);
            
            gpu_set_blendmode_ext(bm_one, bm_one);
            shader_set(__shdBulbIntensity);
            shader_set_uniform_f(_u_fIntensity, hdrBloomIntensity);
            draw_surface_stretched_ext(_bloomSurfaceArray[0], 0, 0, _surfaceWidth, _surfaceHeight, c_white, 1);
            
            gpu_set_blendmode(bm_normal);
            shader_reset();
            
        surface_reset_target();
        
        gpu_set_tex_filter(_oldTextureFiltering);
        gpu_set_blendenable(_oldAlphaBlend);
    }
    
    Free = function()
    {
        __FreeVertexBuffers();
        __FreeLightSurface();
        __FreeOutputSurface();
        __FreeBloomSurfaces();
        __FreeNormalMapSurface();
        
        var _nullFunc = function() {}
        
        //BulbRenderer()
        SetCamera              = _nullFunc;
        GetCamera              = _nullFunc;
        SetSurfaceDimensions   = _nullFunc;
        GetSurfaceDimensions   = _nullFunc;
        Update                 = _nullFunc;
        GetOutputSurface       = _nullFunc;
        DrawLitSurface         = _nullFunc;
        GetTonemap             = _nullFunc;
        RefreshStaticOccluders = _nullFunc;
        __KawaseBloom          = _nullFunc;
        
        //__BulbRendererDefineHDR()
        __GetOutputSurface  = _nullFunc;
        __FreeOutputSurface = _nullFunc;
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
        GetLightSurface    = _nullFunc;
        __FreeLightSurface = _nullFunc;
        GetLightValue      = _nullFunc;
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
    
    
    
    //Assign the ambient colour used for the darkest areas of the screen. This can be changed on the fly
    ambientColor = c_black;
    ambientInGammaSpace = false;
    
    //The smoothing mode controls texture filtering both when accumulating lights and when drawing the resulting surface
    smooth = true;
    
    selfLighting = false;
    
    soft = true;
    __oldSoft = undefined;
    
    exposure   = 1;
    ldrTonemap = BULB_TONEMAP_NONE;
    
    __camera         = undefined;
    __cameraImplicit = false;
    
    __surfaceWidth  = -1;
    __surfaceHeight = -1;
    
    __BulbRendererDefineHDR();
    __BulbRendererDefineNormal();
    __BulbRendererDefineOverlayUnderlay();
    __BulbRendererDefineAccumulateSoft();
    if (_system.__hasStencil) __BulbRendererDefineAccumulateHard() else __BulbRendererDefineAccumulateHardNoStencil();
    __BulbRendererDefineVertexBuffers();
    __BulbRendererDefineLight();
    
    SetCamera(_camera);
}