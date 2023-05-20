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
    
    __rawEdgeArray = [];
    
    __edgeArray   = [];
    __leftArray   = [];
    __topArray    = [];
    __rightArray  = [];
    __bottomArray = [];
    
    static __Finalize = function(_tileWidth, _tileHeight)
    {
        var _rawEdgeArray = __rawEdgeArray;
        
        var _i = 0;
        repeat(array_length(_rawEdgeArray) div __BULB_ARRAY_EDGE_SIZE)
        {
            var _x1 = _rawEdgeArray[_i  ];
            var _y1 = _rawEdgeArray[_i+1];
            var _x2 = _rawEdgeArray[_i+2];
            var _y2 = _rawEdgeArray[_i+3];
            
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
            
            array_push(_writeArray, _x1,
                                    _y1,
                                    _x2,
                                    _y2,
                                    _rawEdgeArray[_i+4],
                                    _rawEdgeArray[_i+5],
                                    _rawEdgeArray[_i+6],
                                    _rawEdgeArray[_i+7]);
            
            _i += __BULB_ARRAY_EDGE_SIZE;
        }
        
        __rawEdgeArray = undefined;
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