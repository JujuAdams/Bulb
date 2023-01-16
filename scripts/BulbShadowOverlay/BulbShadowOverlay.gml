/// @param renderer

function BulbShadowOverlay(_renderer) constructor
{
    visible = true;
    
    sprite = undefined;
    image  = 0;
    
    x = 0;
    y = 0;
    
    xscale = 1.0;
    yscale = 1.0;
    angle  = 0.0;
    
    alpha = 1.0;
    
    __oldSprite = undefined;
    
    __bboxXMin = 0;
    __bboxXMax = 0;
    __bboxYMin = 0;
    __bboxYMax = 0;
    
    __destroyed = false;
    
    static Destroy = function()
    {
        __destroyed = true;
    }
    
    static __CheckSpriteDimensions = function()
    {
        if (__destroyed) return;
        
        // Redefine light sprite boundaries
        if ((sprite != __oldSprite) || (x != xprevious) || (y != yprevious) || (xscale != xscaleprevious) || (yscale != yscaleprevious))
        {
            __oldSprite = sprite;
            
            var _originX =  x - sprite_get_xoffset(sprite) * xscale;
            var _originY =  y - sprite_get_yoffset(sprite) * yscale;
            var _width   = _originX + sprite_get_width(sprite) * xscale;
            var _height  = _originY + sprite_get_height(sprite) * yscale;
            
            __spriteL = min(_originX, _width );
            __spriteT = min(_originY, _height);
            __spriteR = max(_originX, _width );
            __spriteB = max(_originY, _height);
            
            xprevious = x;
            yprevious = y;
            xscaleprevious = xscale;
            yscaleprevious = yscale;
        }
    }
    
    static AddToRenderer = function(_renderer)
    {
        if (__destroyed) return;
        array_push(_renderer.__shadowOverlayArray, weak_ref_create(self));
    }
    
    static RemoveFromRenderer = function(_renderer)
    {
        var _array = _renderer.__shadowOverlayArray;
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
        return (!__destroyed && visible && __BulbRectInRect(__spriteL, __spriteT, __spriteR, __spriteB, _cameraL, _cameraT, _cameraR, _cameraB));
    }
    
    if (_renderer != undefined) AddToRenderer(_renderer);
}