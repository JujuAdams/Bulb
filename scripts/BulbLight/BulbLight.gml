/// @param renderer
/// @param sprite
/// @param image
/// @param x
/// @param y

function BulbLight(_renderer, _sprite, _image, _x, _y) constructor
{
    visible = true;
    
    sprite         = _sprite;
    image          = _image;
    x              = _x;
    y              = _y;
    xprevious      = x;
    yprevious      = y;
    xscale         = 1.0;
    yscale         = 1.0;
    xscaleprevious = xscale;
    yscaleprevious = yscale;
    angle          = 0.0;
    blend          = c_white;
    alpha          = 1.0;
    
    bitmask = BULB_DEFAULT_LIGHT_BITMASK;
    
    penumbraSize = 0.0;
    
    castShadows = true;
    
    __oldSprite  = undefined;
    __spriteL = 0;
    __spriteT = 0;
    __spriteR = 0;
    __spriteB = 0;
    
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
        return (visible && __BulbRectInRect(__spriteL, __spriteT, __spriteR, __spriteB, _cameraL, _cameraT, _cameraR, _cameraB));
    }
    
    static __CheckSpriteDimensions = function()
    {
        // Redefine light sprite boundaries
        if (sprite != __oldSprite || x != xprevious || y != yprevious || xscale != xscaleprevious || yscale != yscaleprevious)
        {
            __oldSprite = sprite;
            __spriteL =  x - sprite_get_xoffset(sprite) * xscale;
			__spriteT =  y - sprite_get_yoffset(sprite) * yscale;
			__spriteR = __spriteL + sprite_get_width(sprite) * xscale;
			__spriteB = __spriteT + sprite_get_height(sprite) * yscale;
        }
    }
    
    // Update the previous variables
    // Maintains correct dimensions for lights
    static __UpdatePreviousVariables = function()
    {
        xprevious = x;
        yprevious = y;
        xscaleprevious = xscale;
        yscaleprevious = yscale;
    }
    
    if (_renderer != undefined) AddToRenderer(_renderer);
}