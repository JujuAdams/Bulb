/// @param renderer

function BulbDynamicOccluder(_renderer) constructor
{
    visible = true;
    
    x = 0;
    y = 0;
    
    xscale = 1.0;
    yscale = 1.0;
    angle  = 0.0;
    
    vertexArray = [];
    
    bitmask = BULB_DEFAULT_DYNAMIC_BITMASK;
    
    __bboxXMin = 0;
    __bboxXMax = 0;
    __bboxYMin = 0;
    __bboxYMax = 0;
    
    __destroyed = false;
    
    static Destroy = function()
    {
        __destroyed = true;
    }
    
    static AddEdge = function(_x1, _y1, _x2, _y2)
    {
        if (__destroyed) return;
        
        __bboxXMin = min(__bboxXMin, __BULB_SQRT_2*_x1, __BULB_SQRT_2*_x2);
        __bboxYMin = min(__bboxYMin, __BULB_SQRT_2*_y1, __BULB_SQRT_2*_y2);
        __bboxXMax = max(__bboxXMax, __BULB_SQRT_2*_x1, __BULB_SQRT_2*_x2);
        __bboxYMax = max(__bboxYMax, __BULB_SQRT_2*_y1, __BULB_SQRT_2*_y2);
        
        array_push(vertexArray, _x1, _y1, _x2, _y2);
    }
    
    static ClearEdges = function(_x1, _y1, _x2, _y2)
    {
        if (__destroyed) return;
        
        __bboxXMin = 0;
        __bboxXMax = 0;
        __bboxYMin = 0;
        __bboxYMax = 0;
        
        array_resize(vertexArray, 0);
    }
    
    static AddToRenderer = function(_renderer)
    {
        if (__destroyed) return;
        array_push(_renderer.__dynamicOccludersArray, weak_ref_create(self));
    }
    
    static RemoveFromRenderer = function(_renderer)
    {
        var _array = _renderer.__dynamicOccludersArray;
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
        return (!__destroyed && visible && __BulbRectInRect(x + __bboxXMin, y + __bboxYMin, x + __bboxXMax, y + __bboxYMax, _cameraL, _cameraT, _cameraR, _cameraB));
    }
    
    if (_renderer != undefined) AddToRenderer(_renderer);
}