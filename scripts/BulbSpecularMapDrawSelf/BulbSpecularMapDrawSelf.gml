// Feather disable all

/// @param value
/// @param [spriteIndex]

function BulbSpecularMapDrawSelf(_value, _spriteIndex = sprite_index)
{
    BulbSpecularMapDrawSpriteExt(_spriteIndex, image_index, x, y, image_xscale, image_yscale, image_angle, _value);
}