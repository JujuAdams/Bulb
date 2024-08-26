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
        
        if ((surfaceWidth <= 0) || (surfaceHeight <= 0)) return undefined;
        
        if ((__normalSurface != undefined) && ((surface_get_width(__normalSurface) != surfaceWidth) || (surface_get_height(__normalSurface) != surfaceHeight)))
        {
            surface_free(__normalSurface);
            __normalSurface = undefined;
        }
        
        if ((__normalSurface == undefined) || !surface_exists(__normalSurface))
        {
            __normalSurface = surface_create(surfaceWidth, surfaceHeight, surface_rgba16float);
            
            surface_set_target(__normalSurface);
            BulbNormalMapClear();
            surface_reset_target();
        }
        
        return __normalSurface;
    }
    
    DrawNormalMapDebug = function(_x, _y, _width, _height)
    {
        shader_set(__shdBulbNormalSurfaceDebug);
        draw_surface_stretched(GetNormalMapSurface(), _x, _y, _width, _height);
        shader_reset();
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