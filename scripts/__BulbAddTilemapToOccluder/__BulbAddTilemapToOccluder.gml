/// @param occluder
/// @param tilemap

function __BulbAddTilemapToOccluder(_occluder, _tilemap)
{
    static _tilesetDict = __BulbGlobal().__tilesetDict;
    
    var _tilesetIndex = tilemap_get_tileset(_tilemap);
    var _tileDict = _tilesetDict[$ _tilesetIndex];
    
    var _tileset = __BulbGetTileset(_tilesetIndex);
    var _tileDict = _tileset.__GetTileDictionary();
    
    var _tileWidth  = tilemap_get_tile_width( _tilemap);
    var _tileHeight = tilemap_get_tile_height(_tilemap);
    
    var _occluderVertexArray = _occluder.__edgeArray;
    
    var _copyArrayFunc = function(_sourceArray, _destinationArray, _xOffset, _yOffset)
    {
        var _j = 0;
        repeat(array_length(_sourceArray) div __BULB_ARRAY_EDGE_SIZE)
        {
            array_push(_destinationArray, _sourceArray[_j  ] + _xOffset,
                                          _sourceArray[_j+1] + _yOffset,
                                          _sourceArray[_j+2] + _xOffset,
                                          _sourceArray[_j+3] + _yOffset,
                                          _sourceArray[_j+4] + _xOffset,
                                          _sourceArray[_j+5] + _yOffset,
                                          _sourceArray[_j+6] + _xOffset,
                                          _sourceArray[_j+7] + _yOffset);
            
            _j += __BULB_ARRAY_EDGE_SIZE;
        }
    }
    
    var _y = 0;
    repeat(tilemap_get_height(_tilemap))
    {
        var _x = 0;
        repeat(tilemap_get_width(_tilemap))
        {
            var _tileIndex = tilemap_get(_tilemap, _x, _y) & tile_index_mask;
            if (_tileIndex > 0)
            {
                var _tile = _tileDict[$ _tileIndex];
                if (is_struct(_tile))
                {
                    var _xOffset = _x*_tileWidth;
                    var _yOffset = _y*_tileHeight;
                    
                    _copyArrayFunc(_tile.__edgeArray, _occluderVertexArray, _xOffset, _yOffset);
                    
                    if (tilemap_get(_tilemap, _x+1, _y) == 0) _copyArrayFunc(_tile.__rightArray,  _occluderVertexArray, _xOffset, _yOffset);
                    if (tilemap_get(_tilemap, _x, _y-1) == 0) _copyArrayFunc(_tile.__topArray,    _occluderVertexArray, _xOffset, _yOffset);
                    if (tilemap_get(_tilemap, _x-1, _y) == 0) _copyArrayFunc(_tile.__leftArray,   _occluderVertexArray, _xOffset, _yOffset);
                    if (tilemap_get(_tilemap, _x, _y+1) == 0) _copyArrayFunc(_tile.__bottomArray, _occluderVertexArray, _xOffset, _yOffset);
                }
            }
            
            ++_x;
        }
        
        ++_y;
    }
}