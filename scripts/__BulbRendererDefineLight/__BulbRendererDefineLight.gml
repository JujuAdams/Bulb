// Feather disable all

function __BulbRendererDefineLight()
{
    //Screen-space surface for final accumulation of lights
    //In HDR mode, this is a per-channel 64-bit RGBA surface
    __lightSurface = undefined;
    
    __lightsArray   = [];
    __sunlightArray = [];
    
    GetLightSurface = function()
    {
        if ((surfaceWidth <= 0) || (surfaceHeight <= 0)) return undefined;
        
        if ((__lightSurface != undefined) && ((surface_get_width(__lightSurface) != surfaceWidth) || (surface_get_height(__lightSurface) != surfaceHeight)))
        {
            surface_free(__lightSurface);
            __lightSurface = undefined;
        }
        
        if ((__lightSurface == undefined) || !surface_exists(__lightSurface))
        {
            __lightSurface = surface_create(surfaceWidth, surfaceHeight, hdr? surface_rgba16float : surface_rgba8unorm);
            
            surface_set_target(__lightSurface);
            draw_clear_alpha(c_black, 1.0);
            surface_reset_target();
        }
        
        return __lightSurface;
    }
    
    __FreeLightSurface = function()
    {
        if ((__lightSurface != undefined) && surface_exists(__lightSurface))
        {
            surface_free(__lightSurface);
            __lightSurface = undefined;
        }
    }
    
    GetLightValue = function(_worldX, _worldY, _cameraL, _cameraT, _cameraW, _cameraH)
    {
        var _surface = GetLightSurface();
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
            
            _result[0] = 255*clamp(power(_result[0], 1/BULB_GAMMA), 0, 1);
            _result[1] = 255*clamp(power(_result[1], 1/BULB_GAMMA), 0, 1);
            _result[2] = 255*clamp(power(_result[2], 1/BULB_GAMMA), 0, 1);
            _result[3] = 255*clamp(, 0, 1);
            
            var _colour = (_result[3] << 24) | (_result[2] << 16) | (_result[1] << 8) | _result[0];
        }
        
        return _colour;
    }
    
    GetLightValueFromCamera = function(_worldX, _worldY, _camera)
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
    
    __AccumulateLights = function(_cameraL, _cameraT, _cameraR, _cameraB, _cameraCX, _cameraCY, _cameraW, _cameraH)
    {
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
}