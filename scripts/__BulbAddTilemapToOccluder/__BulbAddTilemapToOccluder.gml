/// @param occluder
/// @param tilemap

function __BulbAddTilemapToOccluder(_occluder, _tilemap)
{
    var _tilesetIndex = tilemap_get_tileset(_tilemap);
    var _tileDict = global.__bulbTilesetDict[$ _tilesetIndex];
    
    var _tileset = __BulbGetTileset(_tilesetIndex);
    var _tileDict = _tileset.__GetTileDictionary();
    
    var _tileWidth  = tilemap_get_tile_width( _tilemap);
    var _tileHeight = tilemap_get_tile_height(_tilemap);
    
    var _occluderVertexArray = _occluder.vertexArray;
    
    var _copyArrayFunc = function(_sourceArray, _destinationArray, _xOffset, _yOffset)
    {
        var _j = 0;
        repeat(array_length(_sourceArray) div 4)
        {
            //TODO - Optimise this
            var _x1 = _sourceArray[_j  ] + _xOffset;
            var _y1 = _sourceArray[_j+1] + _yOffset;
            var _x2 = _sourceArray[_j+2] + _xOffset;
            var _y2 = _sourceArray[_j+3] + _yOffset;
            array_push(_destinationArray, _x1, _y1, _x2, _y2, _x1, _y1, _x2, _y2);
            
            _j += 4;
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
                    
                    /*if (tilemap_get(_tilemap, _x+1, _y) == 0)*/ _copyArrayFunc(_tile.__rightArray,  _occluderVertexArray, _xOffset, _yOffset);
                    /*if (tilemap_get(_tilemap, _x, _y-1) == 0)*/ _copyArrayFunc(_tile.__topArray,    _occluderVertexArray, _xOffset, _yOffset);
                    /*if (tilemap_get(_tilemap, _x-1, _y) == 0)*/ _copyArrayFunc(_tile.__leftArray,   _occluderVertexArray, _xOffset, _yOffset);
                    /*if (tilemap_get(_tilemap, _x, _y+1) == 0)*/ _copyArrayFunc(_tile.__bottomArray, _occluderVertexArray, _xOffset, _yOffset);
                }
            }
            
            ++_x;
        }
        
        ++_y;
    }
}