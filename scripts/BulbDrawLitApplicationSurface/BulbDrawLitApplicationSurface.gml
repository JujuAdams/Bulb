// Feather disable all

/// @param bulbRenderer
/// @param [x]
/// @param [y]
/// @param [width]
/// @param [height]
/// @param [textureFiltering]
/// @param [alphaBlend]

function BulbDrawLitApplicationSurface(_renderer, _x = undefined, _y = undefined, _width = undefined, _height = undefined, _textureFiltering = undefined, _alphaBlend = undefined)
{
    if ((_x == undefined) || (_y == undefined) || (_width == undefined) || (_height == undefined))
    {
        var _positionArray = application_get_position();
        _x      = _positionArray[0];
        _y      = _positionArray[1];
        _width  = _positionArray[2] - _x;
        _height = _positionArray[3] - _y;
    }
    
    if (_textureFiltering != undefined)
    {
        var _oldTextureFiltering = gpu_get_tex_filter();
        gpu_set_tex_filter(_textureFiltering);
    }
    
    if (_alphaBlend != undefined)
    {
        var _oldAlphaBlend = gpu_get_tex_filter();
        gpu_set_blendenable(_alphaBlend);
    }
    
    if (_renderer == undefined)
    {
        draw_surface_stretched(application_surface, _x, _y, _width, _height);
    }
    else
    {
        _renderer.DrawLitSurface(application_surface, _x, _y, _width, _height);
    }
    
    if (_textureFiltering != undefined)
    {
        gpu_set_tex_filter(_oldTextureFiltering);
    }
    
    if (_alphaBlend != undefined)
    {
        gpu_set_blendenable(_oldAlphaBlend);
    }
}