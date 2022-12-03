/// @param occluder
/// @param spriteIndex
/// @param imageIndex
/// @param xOffset
/// @param yOffset

function __BulbAddSpriteToOccluder(_occluder, _spriteIndex, _imageIndex, _xOffset, _yOffset)
{
    var _trace = (__BulbGetSpriteImage(_spriteIndex, _imageIndex)).__GetTrace();
    
    var _occluderVertexArray = _occluder.vertexArray;
    
    //TODO - Optimise this copy procedure
    //    1. Precompile all loops for an image down to a single array
    //    2. Copy across the entire edge array using array_copy()
    
    var _l = 0;
    repeat(array_length(_trace))
    {
        var _loop = _trace[_l];
        
        var _x1 = undefined;
        var _y1 = undefined;
        var _x2 = _loop[0] + _xOffset;
        var _y2 = _loop[1] + _yOffset;
        
        var _p = 2;
        repeat((array_length(_loop) div 2)-1)
        {
            _x1 = _x2;
            _y1 = _y2;
            _x2 = _loop[_p  ] + _xOffset;
            _y2 = _loop[_p+1] + _yOffset;
            
            array_push(_occluderVertexArray, _x1, _y1,
                                             _x2, _y2,
                                             _y2 - _y1, _x1 - _x2);
            
            _p += 2;
        }
        
        ++_l;
    }
}