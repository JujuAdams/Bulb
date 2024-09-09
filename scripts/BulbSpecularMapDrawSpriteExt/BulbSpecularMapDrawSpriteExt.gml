// Feather disable all

/// @param sprite
/// @param image
/// @param x
/// @param y
/// @param xScale
/// @param yScale
/// @param angle
/// @param value

function BulbSpecularMapDrawSpriteExt(_sprite, _image, _x, _y, _xScale, _yScale, _angle, _value)
{
    draw_sprite_ext(_sprite, _image, _x, _y, _xScale, _yScale, _angle, c_black, _value);
}