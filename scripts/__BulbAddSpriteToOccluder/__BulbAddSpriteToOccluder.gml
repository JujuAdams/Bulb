/// @param occluder
/// @param spriteIndex
/// @param imageIndex
/// @param xOffset
/// @param yOffset
/// @param setRadius

function __BulbAddSpriteToOccluder(_occluder, _spriteIndex, _imageIndex, _xOffset, _yOffset, _setRadius)
{
    var _spriteData = __BulbGetSpriteImage(_spriteIndex, _imageIndex);
    if (_setRadius) _occluder.__radius = max(_occluder.__radius, _spriteData.__radius);
    
    var _destinationArray = _occluder.__edgeArray;
    var _sourceArray      = _spriteData.__GetEdgeArray();
    
    var _i = 0;
    repeat(array_length(_sourceArray) div __BULB_ARRAY_EDGE_SIZE)
    {
        array_push(_destinationArray, _sourceArray[_i  ] + _xOffset,
                                      _sourceArray[_i+1] + _yOffset,
                                      _sourceArray[_i+2] + _xOffset,
                                      _sourceArray[_i+3] + _yOffset,
                                      _sourceArray[_i+4] + _xOffset,
                                      _sourceArray[_i+5] + _yOffset,
                                      _sourceArray[_i+6] + _xOffset,
                                      _sourceArray[_i+7] + _yOffset);
        
        _i += __BULB_ARRAY_EDGE_SIZE;
    }
}