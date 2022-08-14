function BulbEncodeTransformAsColor(_xscale, _yscale, _angle)
{
    _angle = (_angle < 0)? (360 - ((-_angle) mod 360)) : (_angle mod 360);
    
    //Angle is never exactly 1 so normalizedAngle can never be 65536
    var _normalizedAngle = floor(65536 * _angle / 360);
    
    var _red   = _normalizedAngle >> 8;
    var _green = _normalizedAngle & 0xFF;
    var _blue  = (_xscale > 0) | ((_yscale > 0) << 1);
    
    return make_color_rgb(_red, _green, _blue);
}