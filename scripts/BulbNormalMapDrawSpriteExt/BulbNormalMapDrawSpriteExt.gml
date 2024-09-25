// Feather disable all

/// @param sprite
/// @param image
/// @param x
/// @param y
/// @param xScale
/// @param yScale
/// @param angle

function BulbNormalMapDrawSpriteExt(_sprite, _image, _x, _y, _xScale, _yScale, _angle)
{
    var _color = ((frac(_angle/360)*256*256*64) << 2)
               | (((1000000*_xScale) >> 63) & 0x1)
               | (((1000000*_yScale) >> 62) & 0x2);
    
    //The upper 22 bits in the 24-bit color are used to enough the rotation angle.
    //
    //We pack whether the xscale any yscale are negative into the two lowest significant bits of
    //the red component of the color. We do this with a binary hack for extra speed.
    //
    //The multiplication by 1,000,000 is to ensure that scales less than 1 don't get rounded to
    //0 when converted to an integer (which happens implicitly by the left shift operator).
    
    draw_sprite_ext(_sprite, _image, _x, _y, _xScale, _yScale, _angle, _color, 1);
}