// Feather disable all

/// @param bulbRenderer
/// @param surface

function BulbApplyLightingToSurface(_renderer, _surface)
{
    if (_renderer == undefined) return;
    
    surface_copy(_surface, 0, 0, _renderer.GetOutputSurface(_surface));
}
