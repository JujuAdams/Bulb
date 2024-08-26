// Feather disable all

/// @param sprite
/// @param image
/// @param x
/// @param y

function BulbNormalMapDrawSprite(_sprite, _image, _x, _y)
{
    draw_sprite_ext(_sprite, _image, _x, _y, 1, 1, 0, c_black, 1);
}