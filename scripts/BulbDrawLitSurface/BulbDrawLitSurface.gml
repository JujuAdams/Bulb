// Feather disable all

/// @param bulbRenderer
/// @param surface
/// @param [x]
/// @param [y]
/// @param [width]
/// @param [height]
/// @param [textureFiltering]
/// @param [alphaBlend=false]

function BulbDrawLitSurface(_renderer, _surface, _x = undefined, _y = undefined, _width = undefined, _height = undefined, _textureFiltering = undefined, _alphaBlend = false)
{
    if (surface_get_target() == _surface)
    {
        __BulbError("Cannot call BulbDrawLitSurface() when the destination surface and drawn surface are the same\nIf you are drawing the application surface, use a Post-Draw event or GUI draw event");
    }
    
    if ((_x == undefined) || (_y == undefined) || (_width == undefined) || (_height == undefined))
    {
        var _positionArray = application_get_position();
        _x      = _positionArray[0];
        _y      = _positionArray[1];
        _width  = _positionArray[2] - _x;
        _height = _positionArray[3] - _y;
    }
    
    if (_renderer == undefined)
    {
        if (_textureFiltering != undefined)
        {
            var _oldTextureFiltering = gpu_get_tex_filter();
            gpu_set_tex_filter(_textureFiltering);
        }
        
        if (_alphaBlend != undefined)
        {
            var _oldAlphaBlend = gpu_get_blendenable();
            gpu_set_blendenable(_alphaBlend);
        }
        
        draw_surface_stretched(_surface, _x, _y, _width, _height);
        
        if (_textureFiltering != undefined)
        {
            gpu_set_tex_filter(_oldTextureFiltering);
        }
        
        if (_alphaBlend != undefined)
        {
            gpu_set_blendenable(_oldAlphaBlend);
        }
    }
    else
    {
        _renderer.DrawLitSurface(_surface, _x, _y, _width, _height, _textureFiltering, _alphaBlend);
    }
}
