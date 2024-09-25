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
    
    __radius    = 0;
    __destroyed = false;
    
    static Destroy = function()
    {
        __destroyed = true;
    }
    
    static AddEdge = function(_x1, _y1, _x2, _y2)
    {
        if (__destroyed) return;
        
        //Choose the longest axis of the sprite as the radius
        //We apply x/y scaling in the __IsOnScreen() function
        __radius = max(__radius, sqrt(max(_x1*_x1 + _y1*_y1, _x2*_x2 + _y2*_y2)));
        
        array_push(vertexArray, _x1, _y1, _x2, _y2, _y2-_y1, _x1-_x2);
    }
    
    static AddCircle = function(_radius, _x = 0, _y = 0, _edges = 24)
    {
        if (__destroyed) return;
        
        __radius = max(__radius, _radius);
        
        var _angle = 0;
        var _angleStep = 360 / _edges;
        
        var _x2 = _x + lengthdir_x(_radius, _angle);
        var _y2 = _y + lengthdir_y(_radius, _angle);
        
        repeat(_edges)
        { 
            _angle -= _angleStep;
            
            var _x1 = _x2;
            var _y1 = _y2;
            _x2 = _x + lengthdir_x(_radius, _angle);
            _y2 = _y + lengthdir_y(_radius, _angle);
            
            array_push(vertexArray, _x1, _y1, _x2, _y2, _y2-_y1, _x1-_x2);
        }
    }
    
    static ClearEdges = function(_x1, _y1, _x2, _y2)
    {
        if (__destroyed) return;
        
        __radius = 0;
        
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
        var _radius = __radius*max(xscale, yscale);
        return (!__destroyed && visible && __BulbRectInRect(x - _radius, y - _radius, x + _radius, y + _radius, _cameraL, _cameraT, _cameraR, _cameraB));
    }
    
    if (_renderer != undefined) AddToRenderer(_renderer);
}