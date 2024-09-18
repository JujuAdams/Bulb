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
        if ((__surfaceWidth <= 0) || (__surfaceHeight <= 0)) return undefined;
        
        var _surfaceWidth  = floor(__surfaceWidth);
        var _surfaceHeight = floor(__surfaceHeight);
        
        if ((__lightSurface != undefined) && ((surface_get_width(__lightSurface) != _surfaceWidth) || (surface_get_height(__lightSurface) != _surfaceHeight)))
        {
            surface_free(__lightSurface);
            __lightSurface = undefined;
        }
        
        if ((__lightSurface == undefined) || !surface_exists(__lightSurface))
        {
            //Only try to create an HDR surface if floating point surfaces are available
            if (_system.__hdrAvailable)
            {
                //Work around compile error in LTS
                var _surface_create = surface_create;
                __lightSurface = _surface_create(_surfaceWidth, _surfaceHeight, hdr? surface_rgba16float : surface_rgba8unorm);
            }
            else
            {
                __lightSurface = surface_create(_surfaceWidth, _surfaceHeight);
            }
            
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
    
    GetLightValue = function(_worldX, _worldY)
    {
        var _surface = GetLightSurface();
        
        //Deploy PROPER MATHS in case the dev is using matrices
        var _viewMatrix = camera_get_view_mat(__camera);
        var _projMatrix = camera_get_proj_mat(__camera);
        var _cameraW    = round(abs(2/_projMatrix[0]));
        var _cameraH    = round(abs(2/_projMatrix[5]));
        
        var _vector = matrix_transform_vertex(matrix_multiply(_viewMatrix, _projMatrix), _worldX, _worldY, 0);
        var _x      = _cameraW * (0.5 + 0.5*_vector[0]);
        var _y      = _cameraH * (0.5 - 0.5*_vector[1]); //Silly GM matrix quirk
        
        var _result = surface_getpixel_ext(_surface, _x, _y);
        if (not is_array(_result))
        {
            //Unpack 32-bit colour
            var _resultR = ( _result        & 0xFF) / 255;
            var _resultG = ((_result >>  8) & 0xFF) / 255;
            var _resultB = ((_result >> 16) & 0xFF) / 255;
            var _resultA = ((_result >> 24) & 0xFF) / 255;
        }
        else
        {
            //Unpack array of floating point values
            var _resultR = _result[0];
            var _resultG = _result[1];
            var _resultB = _result[2];
            var _resultA = _result[3];
        }
        
        _resultR *= exposure;
        _resultG *= exposure;
        _resultB *= exposure;
        _resultA  = 255*clamp(_resultA, 0, 1); //Clamp the alpha channel
        
        static _funcLuminance = function(_red, _green, _blue)
        {
            return 0.2126*_red + 0.7152*_green + 0.0722*_blue;
        }
        
        var _tonemap = GetTonemap();
        
        if (_tonemap == BULB_TONEMAP_BAD_GAMMA)
        {
            _resultR = 255*clamp(_resultR, 0, 1);
            _resultG = 255*clamp(_resultG, 0, 1);
            _resultB = 255*clamp(_resultB, 0, 1);
        }
        else if (_tonemap == BULB_TONEMAP_HBD)
        {
            _resultR = max(0, _resultR - 0.004);
            _resultG = max(0, _resultG - 0.004);
            _resultB = max(0, _resultB - 0.004);
            
            _resultR = (_resultR * (6.2*_resultR + 0.5)) / (_resultR * (6.2*_resultR + 1.7) + 0.06);
            _resultG = (_resultG * (6.2*_resultG + 0.5)) / (_resultG * (6.2*_resultG + 1.7) + 0.06);
            _resultB = (_resultB * (6.2*_resultB + 0.5)) / (_resultB * (6.2*_resultB + 1.7) + 0.06);
            
            //Already includes gamma correction in calculation, no power() call needed
            _resultR = 255*clamp(_resultR, 0, 1);
            _resultG = 255*clamp(_resultG, 0, 1);
            _resultB = 255*clamp(_resultB, 0, 1);
        }
        else if (_tonemap == BULB_TONEMAP_UNREAL3)
        {
            _resultR = _resultR / (_resultR + 0.155) * 1.019;
            _resultG = _resultG / (_resultG + 0.155) * 1.019;
            _resultB = _resultB / (_resultB + 0.155) * 1.019;
            
            //Already includes gamma correction in calculation, no power() call needed
            _resultR = 255*clamp(_resultR, 0, 1);
            _resultG = 255*clamp(_resultG, 0, 1);
            _resultB = 255*clamp(_resultB, 0, 1);
        }
        else
        {
            if ((_tonemap == BULB_TONEMAP_NONE) || (_tonemap == BULB_TONEMAP_CLAMP))
            {
                //Nothing else needed
            }
            else if (_tonemap == BULB_TONEMAP_REINHARD)
            {
                var _luminance    = _funcLuminance(_resultR, _resultG, _resultB);
                var _luminanceNew = _luminance / (1 + _luminance);
                
                _resultR *= _luminanceNew / _luminance;
                _resultG *= _luminanceNew / _luminance;
                _resultB *= _luminanceNew / _luminance;
            }
            else if (_tonemap == BULB_TONEMAP_REINHARD_EXTENDED)
            {
                var _luminance    = _funcLuminance(_resultR, _resultG, _resultB);
                var _luminanceNew = _luminance * (1.0 + (_luminance / (4*4))) / (1 + _luminance);
                
                _resultR *= _luminanceNew / _luminance;
                _resultG *= _luminanceNew / _luminance;
                _resultB *= _luminanceNew / _luminance;
            }
            else if (_tonemap == BULB_TONEMAP_UNCHARTED2)
            {
                _resultR *= 4;
                _resultG *= 4;
                _resultB *= 4;
                
                static _uc2_A = 0.15;
                static _uc2_B = 0.50;
                static _uc2_C = 0.10;
                static _uc2_D = 0.20;
                static _uc2_E = 0.02;
                static _uc2_F = 0.30;
                
                _resultR = ((_resultR*(_uc2_A*_resultR + _uc2_C*_uc2_B) + _uc2_D*_uc2_E) / (_resultR*(_uc2_A*_resultR + _uc2_B) + _uc2_D*_uc2_F)) - _uc2_E/_uc2_F;
                _resultG = ((_resultG*(_uc2_A*_resultG + _uc2_C*_uc2_B) + _uc2_D*_uc2_E) / (_resultG*(_uc2_A*_resultG + _uc2_B) + _uc2_D*_uc2_F)) - _uc2_E/_uc2_F;
                _resultB = ((_resultB*(_uc2_A*_resultB + _uc2_C*_uc2_B) + _uc2_D*_uc2_E) / (_resultB*(_uc2_A*_resultB + _uc2_B) + _uc2_D*_uc2_F)) - _uc2_E/_uc2_F;
            }
            else if (_tonemap == BULB_TONEMAP_UNREAL3)
            {
                _resultR = max(0, _resultR - 0.004);
                _resultG = max(0, _resultG - 0.004);
                _resultB = max(0, _resultB - 0.004);
                
                _resultR = (_resultR * (6.2*_resultR + 0.5)) / (_resultR * (6.2*_resultR + 1.7) + 0.06);
                _resultG = (_resultG * (6.2*_resultG + 0.5)) / (_resultG * (6.2*_resultG + 1.7) + 0.06);
                _resultB = (_resultB * (6.2*_resultB + 0.5)) / (_resultB * (6.2*_resultB + 1.7) + 0.06);
            }
            else if (_tonemap == BULB_TONEMAP_ACES)
            {
                _resultR = (_resultR*(2.51*_resultR + 0.03)) / (_resultR*(2.43*_resultR + 0.59) + 0.14);
                _resultG = (_resultG*(2.51*_resultG + 0.03)) / (_resultG*(2.43*_resultG + 0.59) + 0.14);
                _resultB = (_resultB*(2.51*_resultB + 0.03)) / (_resultB*(2.43*_resultB + 0.59) + 0.14);
            }
            
            //Final gamma correction stage
            _resultR = 255*clamp(power(_resultR, 1/BULB_GAMMA), 0, 1);
            _resultG = 255*clamp(power(_resultG, 1/BULB_GAMMA), 0, 1);
            _resultB = 255*clamp(power(_resultB, 1/BULB_GAMMA), 0, 1);
        }
        
        return ((_resultA << 24) | (_resultB << 16) | (_resultG << 8) | _resultR);
    }
}