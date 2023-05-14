/// @param renderer
/// @param sprite
/// @param image
/// @param x
/// @param y

function BulbLight(_renderer, _sprite, _image, _x, _y) constructor
{
    visible = true;
    
    x         = _x;
    y         = _y;
    xprevious = x;
    yprevious = y;
    
    sprite = _sprite;
    image  = _image;
    xscale = 1.0;
    yscale = 1.0;
    angle  = 0.0;
    blend  = c_white;
    alpha  = 1.0;
    
    penumbraSize = 0.0;
    
    castShadows = true;
    
    __oldSprite = undefined;
    __radius    = 0;
    __destroyed = false;
    
    static Destroy = function()
    {
        __destroyed = true;
    }
    
    static AddToRenderer = function(_renderer)
    {
        if (__destroyed) return;
        array_push(_renderer.__lightsArray, weak_ref_create(self));
    }
    
    static RemoveFromRenderer = function(_renderer)
    {
        var _array = _renderer.__lightsArray;
        var _i = array_length(_array) - 1;
        repeat(array_length(_array))
        {
            var _weak = _array[_i];
            if (weak_ref_alive(_weak))
            {
                if (_weak.ref == self) array_delete(_array, _i, 1);
            }
            else
            {
                array_delete(_array, _i, 1);
            }
            
            --_i;
        }
    }
    
    static __CheckSpriteDimensions = function()
    {
        // Redefine light sprite boundaries
        if (sprite != __oldSprite)
        {
            __oldSprite = sprite;
            
            if ((sprite != undefined) && sprite_exists(sprite))
            {
                //Choose the longest axis of the sprite as the radius
                //We apply x/y scaling in the __IsOnScreen() function
                var _xOffset = sprite_get_xoffset(sprite);
                var _yOffset = sprite_get_yoffset(sprite);
                var _x = max(_xOffset, sprite_get_width( sprite) - _xOffset);
                var _y = max(_yOffset, sprite_get_height(sprite) - _yOffset);
                
                __radius = sqrt(_x*_x + _y*_y);
            }
            else
            {
                __radius = 0;
            }
        }
    }
    
    static __IsOnScreen = function(_cameraL, _cameraT, _cameraR, _cameraB)
    {
        var _radius = __radius*max(xscale, yscale);
        return (!__destroyed && visible && __BulbRectInRect(x - _radius, y - _radius, x + _radius, y + _radius, _cameraL, _cameraT, _cameraR, _cameraB));
    }
    
    if (_renderer != undefined) AddToRenderer(_renderer);
}