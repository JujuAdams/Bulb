/// @param renderer

function BulbStaticOccluder(_renderer) constructor
{
    x = 0;
    y = 0;
    
    xscale = 1.0;
    yscale = 1.0;
    angle  = 0.0;
    
    vertexArray = [];
    
    __bboxXMin = 0;
    __bboxXMax = 0;
    __bboxYMin = 0;
    __bboxYMax = 0;
    
    static AddEdge = function(_x1, _y1, _x2, _y2)
    {
        __bboxXMin = min(__bboxXMin, __BULB_SQRT_2*_x1, __BULB_SQRT_2*_x2);
        __bboxYMin = min(__bboxYMin, __BULB_SQRT_2*_y1, __BULB_SQRT_2*_y2);
        __bboxXMax = max(__bboxXMax, __BULB_SQRT_2*_x1, __BULB_SQRT_2*_x2);
        __bboxYMax = max(__bboxYMax, __BULB_SQRT_2*_y1, __BULB_SQRT_2*_y2);
        
        array_push(vertexArray, _x1, _y1, _x2, _y2);
    }
    
    static AddToRenderer = function(_renderer)
    {
        array_push(_renderer.__staticOccludersArray, weak_ref_create(self));
    }
    
    static __IsOnScreen = function(_cameraL, _cameraT, _cameraR, _cameraB)
    {
        return (visible && __BulbRectInRect(__bboxXMin, __bboxYMin, __bboxXMax, __bboxYMax, _cameraL, _cameraT, _cameraR, _cameraB));
    }
    
    if (_renderer != undefined) AddToRenderer(_renderer);
}