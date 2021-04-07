/// @param renderer
/// @param sprite
/// @param image
/// @param x
/// @param y

function BulbLight(_renderer, _sprite, _image, _x, _y) constructor
{
    visible = true;
    
    sprite = _sprite;
    image  = _image;
    x      = _x;
    y      = _y;
    xscale = 1.0;
    yscale = 1.0;
    angle  = 0.0;
    blend  = c_white;
    alpha  = 1.0;
    
    bitmask = BULB_DEFAULT_LIGHT_BITMASK;
    
    penumbraSize = 0.0;
    
    castShadows = true;
    
    __oldSprite  = undefined;
    __widthHalf  = 0;
    __heightHalf = 0;
    
    static AddToRenderer = function(_renderer)
    {
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
    
    static __IsOnScreen = function(_cameraL, _cameraT, _cameraR, _cameraB)
    {
        return (visible && __BulbRectInRect(x - __widthHalf, y - __heightHalf, x + __widthHalf, y + __heightHalf, _cameraL, _cameraT, _cameraR, _cameraB));
    }
    
    static __CheckSpriteDimensions = function()
    {
        if (sprite != __oldSprite)
        {
            __oldSprite = sprite;
            
            __widthHalf  = 0.5*xscale*sprite_get_width(sprite);
            __heightHalf = 0.5*yscale*sprite_get_height(sprite);
        }
    }
    
    if (_renderer != undefined) AddToRenderer(_renderer);
}