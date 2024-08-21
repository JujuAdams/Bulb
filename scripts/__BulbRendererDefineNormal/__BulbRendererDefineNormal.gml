// Feather disable all

function __BulbRendererDefineNormal()
{
    normalMapped = false;
    __oldNormalMapped = undefined;
    
    normalMapAlphaThreshold = BULB_DEFAULT_NORMAL_MAP_ALPHA_THRESHOLD;
    
    __normalSurface = undefined;
    
    
    
    NormalSurfaceClear = function()
    {
        surface_set_target(GetNormalSurface());
        draw_clear(c_black);
        surface_reset_target();
    }
    
    NormalSurfaceStartDraw = function(_alphaThreshold = normalMapAlphaThreshold)
    {
        if (not normalMapped)
        {
            __BulbError("Cannot call .NormalSurfaceStartDraw(), .normalMapped is not set to `true`");
        }
        
        static _u_fAlphaThreshold = shader_get_uniform(__shdBulbNormal, "u_fAlphaThreshold");
        
        surface_set_target(GetNormalSurface());
        shader_set(__shdBulbNormal);
        shader_set_uniform_f(_u_fAlphaThreshold, normalMapAlphaThreshold);
    }
    
    NormalSurfaceEndDraw = function()
    {
        if (not normalMapped)
        {
            __BulbError("Cannot call .NormalSurfaceEndDraw(), .normalMapped is not set to `true`");
        }
        
        surface_reset_target();
        shader_reset();
    }
    
    GetNormalSurface = function()
    {
        if (not normalMapped)
        {
            __BulbError("Cannot call .GetNormalSurface(), .normalMapped is not set to `true`");
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
            draw_clear(c_black);
            surface_reset_target();
        }
        
        return __normalSurface;
    }
    
    DrawNormalSurfaceDebug = function(_x, _y, _width, _height)
    {
        shader_set(__shdBulbNormalSurfaceDebug);
        draw_surface_stretched(GetNormalSurface(), _x, _y, _width, _height);
        shader_reset();
    }
    
    __FreeNormalSurface = function()
    {
        if ((__normalSurface != undefined) && surface_exists(__normalSurface))
        {
            surface_free(__normalSurface);
            __normalSurface = undefined;
        }
    }
}