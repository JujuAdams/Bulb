/// @param tileset
/// @param tileIndex
/// @param x
/// @param y

function __BulbClassTile(_tileset, _tileIndex, _x, _y) constructor
{
    __tileset   = _tileset;
    __tileIndex = _tileIndex;
    __x         = _x;
    __y         = _y;
    
    __loopArray = [];
    __edgeArray = [];
    
    __leftArray   = [];
    __topArray    = [];
    __rightArray  = [];
    __bottomArray = [];
    
    static __Finalize = function(_tileWidth, _tileHeight)
    {
        var _completeArray = [];
        
        var _i = 0;
        repeat(array_length(__loopArray))
        {
            var _pointArray = __loopArray[_i];
            __BulbAddTilemapToOccluderInternal(_completeArray, _pointArray, 0, array_length(_pointArray)-2);
            ++_i;
        }
        
        var _i = 0;
        repeat(array_length(_completeArray) div __BULB_ARRAY_VERTEX_SIZE)
        {
            var _x1 = _completeArray[_i  ];
            var _y1 = _completeArray[_i+1];
            var _x2 = _completeArray[_i+2];
            var _y2 = _completeArray[_i+3];
            
            if ((_x1 <= 0) && (_x2 <= 0))
            {
                var _writeArray = __leftArray;
            }
            else if ((_y1 <= 0) && (_y2 <= 0))
            {
                var _writeArray = __topArray;
            }
            else if ((_x1 >=  _tileWidth) && (_x2 >=  _tileWidth))
            {
                var _writeArray = __rightArray;
            }
            else if ((_y1 >= _tileHeight) && (_y2 >= _tileHeight))
            {
                var _writeArray = __bottomArray;
            }
            else
            {
                var _writeArray = __edgeArray;
            }
            
            array_push(_writeArray, _x1, _y1, _x2, _y2,
                                    _completeArray[_i+4],
                                    _completeArray[_i+5],
                                    _completeArray[_i+6],
                                    _completeArray[_i+7]);
            
            _i += __BULB_ARRAY_VERTEX_SIZE;
        }
        
        __loopArray = undefined;
    }
    
    static __BufferWrite = function(_buffer)
    {
        var _i = 0;
        repeat(5)
        {
            switch(_i)
            {
                case 0: var _array = __edgeArray;   break;
                case 1: var _array = __leftArray;   break;
                case 2: var _array = __topArray;    break;
                case 3: var _array = __rightArray;  break;
                case 4: var _array = __bottomArray; break;
            }
            
            buffer_write(_buffer, buffer_u64, array_length(_array));
            var _j = 0;
            repeat(array_length(_array))
            {
                buffer_write(_buffer, buffer_s16, _array[_j]);
                ++_j;
            }
            
            ++_i;
        }
    }
    
    static __BufferRead = function(_buffer)
    {
        var _i = 0;
        repeat(5)
        {
            switch(_i)
            {
                case 0: var _array = __edgeArray;   break;
                case 1: var _array = __leftArray;   break;
                case 2: var _array = __topArray;    break;
                case 3: var _array = __rightArray;  break;
                case 4: var _array = __bottomArray; break;
            }
            
            var _size = buffer_read(_buffer, buffer_u64);
            array_resize(_array, _size);
            
            var _j = 0;
            repeat(_size)
            {
                _array[@ _j] = buffer_read(_buffer, buffer_s16);
                ++_j;
            }
            
            ++_i;
        }
    }
}

function __BulbAddTilemapToOccluderInternal(_occluderVertexArray, _pointArray, _start, _end, _epsilon = 1)
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
            __BulbAddTilemapToOccluderInternal(_occluderVertexArray, _pointArray, _start, _maxPoint, _epsilon);
            __BulbAddTilemapToOccluderInternal(_occluderVertexArray, _pointArray, _maxPoint, _end, _epsilon);
        }
    }
    
    if (_maxDist < _epsilon)
    {
        var _x3 = undefined;
        var _y3 = undefined;
        var _x4 = _pointArray[_start  ];
        var _y4 = _pointArray[_start+1];
        
        var _p = _start + 2;
        repeat((_end - _start) div 2)
        {
            _x3 = _x4;
            _y3 = _y4;
            var _x4 = _pointArray[_p  ];
            var _y4 = _pointArray[_p+1];
            
            array_push(_occluderVertexArray, _x3, _y3,
                                             _x4, _y4,
                                             _x1, _y1,
                                             _x2, _y2);
            
            _p += 2;
        }
    }
}