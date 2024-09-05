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
            _result[0] *= exposure;
            _result[1] *= exposure;
            _result[2] *= exposure;
            _result[3]  = clamp(_result[3], 0, 1); //Clamp the alpha channel
            
            static _funcLuminance = function(_red, _green, _blue)
            {
                return 0.2126*_red + 0.7152*_green + 0.0722*_blue;
            }
            
            var _tonemap = GetTonemap();
            
            if (_tonemap == BULB_TONEMAP_BAD_GAMMA)
            {
                _result[0] = 255*clamp(_result[0], 0, 1);
                _result[1] = 255*clamp(_result[1], 0, 1);
                _result[2] = 255*clamp(_result[2], 0, 1);
            }
            else if (_tonemap == BULB_TONEMAP_HBD)
            {
                var _r = max(0, _result[0] - 0.004);
                var _g = max(0, _result[1] - 0.004);
                var _b = max(0, _result[2] - 0.004);
                
                _r = (_r * (6.2*_r + 0.5)) / (_r * (6.2*_r + 1.7) + 0.06);
                _g = (_g * (6.2*_g + 0.5)) / (_g * (6.2*_g + 1.7) + 0.06);
                _b = (_b * (6.2*_b + 0.5)) / (_b * (6.2*_b + 1.7) + 0.06);
                
                _result[0] = 255*clamp(_r, 0, 1);
                _result[1] = 255*clamp(_g, 0, 1);
                _result[2] = 255*clamp(_b, 0, 1);
            }
            else if (_tonemap == BULB_TONEMAP_UNREAL3)
            {
                var _r = _result[0];
                var _g = _result[1];
                var _b = _result[2];
                
                _r = _r / (_r + 0.155) * 1.019;
                _g = _g / (_g + 0.155) * 1.019;
                _b = _b / (_b + 0.155) * 1.019;
                
                _result[0] = 255*clamp(_r, 0, 1);
                _result[1] = 255*clamp(_g, 0, 1);
                _result[2] = 255*clamp(_b, 0, 1);
            }
            else
            {
                if (_tonemap == BULB_TONEMAP_CLAMP)
                {
                    //Nothing else needed
                }
                else if (_tonemap == BULB_TONEMAP_REINHARD)
                {
                    var _luminance    = _funcLuminance(_result[0], _result[1], _result[2]);
                    var _luminanceNew = _luminance / (1 + _luminance);
                    
                    _result[0] *= _luminanceNew / _luminance;
                    _result[1] *= _luminanceNew / _luminance;
                    _result[2] *= _luminanceNew / _luminance;
                }
                else if (_tonemap == BULB_TONEMAP_REINHARD_EXTENDED)
                {
                    var _luminance    = _funcLuminance(_result[0], _result[1], _result[2]);
                    var _luminanceNew = _luminance * (1.0 + (_luminance / (4*4))) / (1 + _luminance);
                    
                    _result[0] *= _luminanceNew / _luminance;
                    _result[1] *= _luminanceNew / _luminance;
                    _result[2] *= _luminanceNew / _luminance;
                }
                else if (_tonemap == BULB_TONEMAP_UNCHARTED2)
                {
                    var _r = 4*_result[0];
                    var _g = 4*_result[1];
                    var _b = 4*_result[2];
                    
                    static _uc2_A = 0.15;
                    static _uc2_B = 0.50;
                    static _uc2_C = 0.10;
                    static _uc2_D = 0.20;
                    static _uc2_E = 0.02;
                    static _uc2_F = 0.30;
                    
                    _result[0] = ((_r*(_uc2_A*_r+_uc2_C*_uc2_B)+_uc2_D*_uc2_E)/(_r*(_uc2_A*_r+_uc2_B)+_uc2_D*_uc2_F))-_uc2_E/_uc2_F;
                    _result[1] = ((_g*(_uc2_A*_g+_uc2_C*_uc2_B)+_uc2_D*_uc2_E)/(_g*(_uc2_A*_g+_uc2_B)+_uc2_D*_uc2_F))-_uc2_E/_uc2_F;
                    _result[2] = ((_b*(_uc2_A*_b+_uc2_C*_uc2_B)+_uc2_D*_uc2_E)/(_b*(_uc2_A*_b+_uc2_B)+_uc2_D*_uc2_F))-_uc2_E/_uc2_F;
                }
                else if (_tonemap == BULB_TONEMAP_UNREAL3)
                {
                    var _r = max(0, _result[0] - 0.004);
                    var _g = max(0, _result[1] - 0.004);
                    var _b = max(0, _result[2] - 0.004);
                    
                    _result[0] = (_r * (6.2*_r + 0.5)) / (_r * (6.2*_r + 1.7) + 0.06);
                    _result[1] = (_g * (6.2*_g + 0.5)) / (_g * (6.2*_g + 1.7) + 0.06);
                    _result[2] = (_b * (6.2*_b + 0.5)) / (_b * (6.2*_b + 1.7) + 0.06);
                }
                else if (_tonemap == BULB_TONEMAP_ACES)
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
            }
            
            _result[3] = 255*clamp(_result[3], 0, 1);
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
}