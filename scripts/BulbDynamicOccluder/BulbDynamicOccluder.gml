/// @param renderer

function BulbDynamicOccluder(_renderer) constructor
{
    visible = true;
    
    x = 0;
    y = 0;
    
    xscale = 1.0;
    yscale = 1.0;
    angle  = 0.0;
    
    //Arranged as repeating units of 6 elements: x1, y1, x2, y2, normal x, normal y
    //The normal vector does *not* need to be of unit length
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
    
    static AddEdge = function(_x1, _y1, _x2, _y2, _nx = (_y2 - _y1), _ny = (_x1 - _x2))
    {
        if (__destroyed) return;
        
        __bboxXMin = min(__bboxXMin, __BULB_SQRT_2*_x1, __BULB_SQRT_2*_x2);
        __bboxYMin = min(__bboxYMin, __BULB_SQRT_2*_y1, __BULB_SQRT_2*_y2);
        __bboxXMax = max(__bboxXMax, __BULB_SQRT_2*_x1, __BULB_SQRT_2*_x2);
        __bboxYMax = max(__bboxYMax, __BULB_SQRT_2*_y1, __BULB_SQRT_2*_y2);
        
        array_push(vertexArray, _x1, _y1, _x2, _y2, _nx, _ny);
        
        return self;
    }
    
    //Not used at this time
    //static AddEdgesFromArray = function(_array)
    //{
    //    if (__destroyed) return;
    //    
    //    var _oldLength = array_length(vertexArray);
    //    var _newLength = array_length(_array);
    //    array_resize(vertexArray, _oldLength + _newLength);
    //    array_copy(vertexArray, _oldLength, _array, 0, _newLength);
    //    
    //    return self;
    //}
    
    static SetSprite = function(_sprite, _image)
    {
        ClearEdges();
        AddSprite(_sprite, _image);
    }
    
    static SetTilemap = function(_tilemap)
    {
        ClearEdges();
        AddTilemap(_tilemap);
    }
    
    static AddSprite = function(_sprite, _image, _xOffset = 0, _yOffset = 0)
    {
        __BulbAddSpriteToOccluder(self, _sprite, _image, _xOffset, _yOffset);
    }
    
    static AddTilemap = function(_tilemap)
    {
        if (is_string(_tilemap)) _tilemap = layer_tilemap_get_id(_tilemap);
        __BulbAddTilemapToOccluder(self, _tilemap);
    }
    
    static ClearEdges = function()
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