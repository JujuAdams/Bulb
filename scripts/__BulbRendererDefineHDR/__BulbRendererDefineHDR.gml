// Feather disable all

function __BulbRendererDefineHDR()
{
    hdr         = false;
    hdrTonemap  = BULB_TONEMAP_HBD;
    
    hdrBloomIntensity    = 0;
    hdrBloomIterations   = 3;
    hdrBloomThresholdMin = 0.6;
    hdrBloomThresholdMax = 0.8;
    
    __oldHDR                = undefined;
    __oldHDRBloomIterations = undefined;
    
    //Surface used for HDR composition prior to tonemapping
    //This is a per-channel 64-bit RGBA surface and is only created on demand (i.e. in HDR mode)
    __hdrSurface = undefined;
    
    __bloomSurfaceArray = [];
    
    
    
    __GetHDRSurface = function(_width, _height)
    {
        if ((_width <= 0) || (_height <= 0)) return undefined;
        
        if ((__hdrSurface != undefined) && ((surface_get_width(__hdrSurface) != _width) || (surface_get_height(__hdrSurface) != _height)))
        {
            surface_free(__hdrSurface);
            __hdrSurface = undefined;
        }
        
        if ((__hdrSurface == undefined) || !surface_exists(__hdrSurface))
        {
            //Work around compile error in LTS
            var _surface_create = surface_create;
            __hdrSurface = _surface_create(_width, _height, surface_rgba16float);
            
            surface_set_target(__hdrSurface);
            draw_clear(c_black);
            surface_reset_target();
            
            __FreeBloomSurfaces();
        }
        
        return __hdrSurface;
    }
    
    __FreeHDRSurface = function()
    {
        if ((__hdrSurface != undefined) && surface_exists(__hdrSurface))
        {
            surface_free(__hdrSurface);
            __hdrSurface = undefined;
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