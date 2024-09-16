// Feather disable all

function __BulbRendererDefineHDR()
{
    static _system = __BulbSystem();
    
    hdr         = false;
    hdrTonemap  = BULB_TONEMAP_HBD;
    
    hdrBloomIntensity    = 0;
    hdrBloomIterations   = 3;
    hdrBloomThresholdMin = 0.4;
    hdrBloomThresholdMax = 0.9;
    
    __oldHDR                = undefined;
    __oldHDRBloomIterations = undefined;
    
    //Surface used for HDR composition prior to tonemapping
    //This is a 16-bit float RGBA surface and is only created on demand
    __outputSurface = undefined;
    
    __bloomSurfaceArray = [];
    
    
    
    __GetOutputSurface = function(_width, _height)
    {
        if ((_width <= 0) || (_height <= 0)) return undefined;
        
        if ((__outputSurface != undefined) && ((surface_get_width(__outputSurface) != _width) || (surface_get_height(__outputSurface) != _height)))
        {
            surface_free(__outputSurface);
            __outputSurface = undefined;
        }
        
        if ((__outputSurface == undefined) || !surface_exists(__outputSurface))
        {
            if (hdr && _system.__hdrAvailable)
            {
                //Work around compile error in LTS
                var _surface_create = surface_create;
                __outputSurface = _surface_create(_width, _height, surface_rgba16float);
            }
            else
            {
                __outputSurface = surface_create(_width, _height);
            }
            
            surface_set_target(__outputSurface);
            draw_clear(c_black);
            surface_reset_target();
            
            __FreeBloomSurfaces();
        }
        
        return __outputSurface;
    }
    
    __FreeOutputSurface = function()
    {
        if ((__outputSurface != undefined) && surface_exists(__outputSurface))
        {
            surface_free(__outputSurface);
            __outputSurface = undefined;
        }
    }
    
    __FreeBloomSurfaces = function()
    {
        var _i = 0;
        repeat(array_length(__bloomSurfaceArray))
        {
            surface_free(__bloomSurfaceArray[_i]);
            ++_i;
        }
        
        array_resize(__bloomSurfaceArray, 0);
    }
}