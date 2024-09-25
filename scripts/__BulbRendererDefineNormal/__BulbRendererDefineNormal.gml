// Feather disable all

function __BulbRendererDefineNormal()
{
    normalMap = BULB_DEFAULT_USE_NORMAL_MAP;
    __oldNormalMap = undefined;
    
    __normalSurface = undefined;
    
    
    
    GetNormalMapSurface = function()
    {
        if (not normalMap)
        {
            __BulbError("Cannot call .GetNormalMapSurface(), `normalMap` is not set to `true`");
        }
        
        if ((__surfaceWidth <= 0) || (__surfaceHeight <= 0)) return undefined;
        
        if ((__normalSurface != undefined) && ((surface_get_width(__normalSurface) != __surfaceWidth) || (surface_get_height(__normalSurface) != __surfaceHeight)))
        {
            surface_free(__normalSurface);
            __normalSurface = undefined;
        }
        
        if ((__normalSurface == undefined) || !surface_exists(__normalSurface))
        {
            __normalSurface = surface_create(__surfaceWidth, __surfaceHeight);
            
            surface_set_target(__normalSurface);
            BulbNormalMapClear();
            surface_reset_target();
        }
        
        return __normalSurface;
    }
    
    DrawNormalMapDebug = function(_x, _y, _width, _height)
    {
        draw_surface_stretched(GetNormalMapSurface(), _x, _y, _width, _height);
    }
    
    __FreeNormalMapSurface = function()
    {
        if ((__normalSurface != undefined) && surface_exists(__normalSurface))
        {
            surface_free(__normalSurface);
            __normalSurface = undefined;
        }
    }
}