function __BulbEncodeTransformAsColor(_xscale, _yscale, _angle)
{
    //Ensure the angle is 0 <= angle < 360
    _angle = (_angle < 0)? (360 - ((-_angle) mod 360)) : (_angle mod 360);
    
    //Scale up to 0 <= normAngle < 65536
    //Angle is never exactly 1 so normalizedAngle can never be 65536
    var _normalizedAngle = floor(65536 * _angle / 360);
    
    //Pack the angle into two bytes
    var _red   = _normalizedAngle >> 8;
    var _green = _normalizedAngle & 0xFF;
    
    //Pack the parity of the x/y scales
    //These are used to correct normals for flipped sprites
    var _blue  = (_xscale >= 0) | ((_yscale >= 0) << 1);
    
    return make_color_rgb(_red, _green, _blue);
}