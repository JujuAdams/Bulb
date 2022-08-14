/// @param sprite
/// @param index
/// @param x
/// @param y
/// @param xscale
/// @param yscale
/// @param angle

function BulbDrawNormal(_sprite, _index, _x, _y, _xscale, _yscale, _angle)
{
    draw_sprite_ext(_sprite, _index, _x, _y, _xscale, _yscale, _angle, BulbEncodeTransformAsColor(_xscale, _yscale, _angle), 1.0);
}