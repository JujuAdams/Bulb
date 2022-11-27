/// @param occluder
/// @param spriteIndex
/// @param imageIndex

function __BulbAddSpriteToOccluder(_occluder, _spriteIndex, _imageIndex)
{
    var _trace = (__BulbGetSpriteImage(_spriteIndex, _imageIndex)).__GetTrace();
    
    var _l = 0;
    repeat(array_length(_trace))
    {
        var _loop = _trace[_l];
        
        var _x1 = undefined;
        var _y1 = undefined;
        var _x2 = _loop[0];
        var _y2 = _loop[1];
        
        var _p = 2;
        repeat((array_length(_loop) div 2)-1)
        {
            _x1 = _x2;
            _y1 = _y2;
            _x2 = _loop[_p  ];
            _y2 = _loop[_p+1];
            
            _occluder.AddEdge(_x1, _y1, _x2, _y2);
            
            _p += 2;
        }
        
        ++_l;
    }
}