var _count = 50;

lightArray = [];

var _i = 0;
var _y = 0;
repeat(_count)
{
    var _light = new BulbLight(oRendererPar.renderer, sLight1024, 0, x, y + _y);
    _light.blend = make_colour_hsv(lerp(0, 150, _i), 230, 230);
    _light.intensity = 0.02;
    
    lightArray[_y] = _light;
    
    _i += 1 / (_count-1);
    _y += 10;
}