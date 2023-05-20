/// @param occluder
/// @param spriteIndex
/// @param imageIndex
/// @param xOffset
/// @param yOffset
/// @param setRadius

function __BulbAddSpriteToOccluder(_occluder, _spriteIndex, _imageIndex, _xOffset, _yOffset, _setRadius)
{
    var _spriteData = __BulbGetSpriteImage(_spriteIndex, _imageIndex);
    if (_setRadius) _occluder.radius = max(_occluder.radius, _spriteData.radius);
    
    //TODO - Optimise this copy procedure by precompiling all loops for an image down to a single array
    
    var _loopArray = _spriteData.__GetTrace();
    var _occluderVertexArray = _occluder.vertexArray;
    var _l = 0;
    repeat(array_length(_loopArray))
    {
        var _pointArray = _loopArray[_l];
        __BulbAddSpriteToOccluderInternal(_occluderVertexArray, _xOffset, _yOffset, _pointArray, 0, array_length(_pointArray)-2);
        ++_l;
    }
}

function __BulbAddSpriteToOccluderInternal(_occluderVertexArray, _xOffset, _yOffset, _pointArray, _start, _end, _epsilon = 1)
{
    var _maxDist = 0;
    
    var _x1 = _pointArray[_start  ];
    var _y1 = _pointArray[_start+1];
    var _x2 = _pointArray[_end    ];
    var _y2 = _pointArray[_end+1  ];
    
    var _dx = _x2 - _x1;
    var _dy = _y2 - _y1;
    
    if (_end - _start >= 4)
    {
        var _lengthSquared = _dx*_dx + _dy*_dy;
        
        if (_lengthSquared == 0)
        {
            var _maxDist  = 0;
            var _maxPoint = undefined;
            var _p = _start+2;
            repeat(((_end - _start) div 2) - 1)
            {
                var _x = _pointArray[_p  ];
                var _y = _pointArray[_p+1];
                
                var _distance = point_distance(_x1, _y1, _x, _y);
                if (_distance >= _maxDist)
                {
                    _maxDist  = _distance;
                    _maxPoint = _p;
                }
                
                _p += 2;
            }
        }
        else
        {
            var _maxPoint = undefined;
            var _p = _start+2;
            repeat(((_end - _start) div 2) - 1)
            {
                var _x = _pointArray[_p  ];
                var _y = _pointArray[_p+1];
                
                var _t = real((_x - _x1)*_dx + (_y - _y1)*_dy) / _lengthSquared;
                _t = clamp(_t, 0, 1);
                
                var _xP = _x1 + _t*_dx;
                var _yP = _y1 + _t*_dy;
                
                var _perpendicularDistance = point_distance(_x, _y, _xP, _yP);
                if (_perpendicularDistance >= _maxDist)
                {
                    _maxDist  = _perpendicularDistance;
                    _maxPoint = _p;
                }
                
                _p += 2;
            }
        }
        
        if (_maxDist >= _epsilon)
        {
            __BulbAddSpriteToOccluderInternal(_occluderVertexArray, _xOffset, _yOffset, _pointArray, _start, _maxPoint, _epsilon);
            __BulbAddSpriteToOccluderInternal(_occluderVertexArray, _xOffset, _yOffset, _pointArray, _maxPoint, _end, _epsilon);
        }
    }
    
    if (_maxDist < _epsilon)
    {
        var _x3 = undefined;
        var _y3 = undefined;
        var _x4 = _pointArray[_start  ] + _xOffset;
        var _y4 = _pointArray[_start+1] + _yOffset;
        
        var _p = _start + 2;
        repeat((_end - _start) div 2)
        {
            _x3 = _x4;
            _y3 = _y4;
            var _x4 = _pointArray[_p  ] + _xOffset;
            var _y4 = _pointArray[_p+1] + _yOffset;
            
            array_push(_occluderVertexArray, _x3, _y3,
                                             _x4, _y4,
                                             _x1, _y1,
                                             _x2, _y2);
            
            _p += 2;
        }
    }
}