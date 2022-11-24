/// @param spriteEdge
/// @param [epsilon=1]

function BulbSpriteEdgeSimplify(_loopArray, _epsilon = 1)
{
    var _l = 0;
    repeat(array_length(_loopArray))
    {
        var _pointArray = _loopArray[_l];
        __BulbSpriteEdgeSimplify(_pointArray, 0, array_length(_pointArray)-2, _epsilon);
        ++_l;
    }
}

function __BulbSpriteEdgeSimplify(_pointArray, _start, _end, _epsilon)
{
    if (_end - _start < 4) return;
    
    var _x1 = _pointArray[_start  ];
    var _y1 = _pointArray[_start+1];
    var _x2 = _pointArray[_end    ];
    var _y2 = _pointArray[_end+1  ];
    
    var _dx = _x2 - _x1;
    var _dy = _y2 - _y1;
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
        var _maxDist  = 0;
        var _maxPoint = undefined;
        var _p = _start+2;
        repeat(((_end - _start) div 2) - 1)
        {
            var _x = _pointArray[_p  ];
            var _y = _pointArray[_p+1];
            
            var _t = ((_x - _x1)*_dx + (_y - _y1)*_dy) / _lengthSquared;
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
        __BulbSpriteEdgeSimplify(_pointArray, _maxPoint, _end, _epsilon);
        __BulbSpriteEdgeSimplify(_pointArray, _start, _maxPoint, _epsilon);
    }
    else
    {
        array_delete(_pointArray, _start+2, _end - _start - 2);
    }
}