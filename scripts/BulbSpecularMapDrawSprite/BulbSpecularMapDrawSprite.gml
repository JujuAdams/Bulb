// Feather disable all

/// @param sprite
/// @param image
/// @param x
/// @param y
/// @param value

function BulbSpecularMapDrawSprite(_sprite, _image, _x, _y, _value)
{
    draw_sprite_ext(_sprite, _image, _x, _y, 1, 1, 0, c_black, _value);
}