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
    
    var _y = 0;
    repeat(tilemap_get_height(_tilemap))
    {
        var _x = 0;
        repeat(tilemap_get_width(_tilemap))
        {
            var _tileIndex = tilemap_get(_tilemap, _x, _y) & tile_index_mask;
            if (_tileIndex > 0)
            {
                var _loopArray = _tileDict[$ _tileIndex];
                if (is_array(_loopArray))
                {
                    var _xOffset = _x*_tileWidth;
                    var _yOffset = _y*_tileHeight;
                    
                    var _i = 0;
                    repeat(array_length(_loopArray))
                    {
                        var _loop = _loopArray[_i];
                        
                        var _x1 = undefined;
                        var _y1 = undefined;
                        var _x2 = _loop[0];
                        var _y2 = _loop[1];
                        
                        var _j = 2;
                        repeat((array_length(_loop) div 2)-1)
                        {
                            _x1 = _x2;
                            _y1 = _y2;
                            _x2 = _loop[_j  ];
                            _y2 = _loop[_j+1];
                            
                            if (((_x1 <= 0) && (_x2 <= 0))
                            ||  ((_y1 <= 0) && (_y2 <= 0))
                            ||  ((_x1 >= _tileWidth) && (_x2 >= _tileWidth))
                            ||  ((_y1 >= _tileHeight) && (_y2 >= _tileHeight)))
                            {
                            
                            }
                            else
                            {
                                _occluder.AddEdge(_x1 + _xOffset, _y1 + _yOffset, _x2 + _xOffset, _y2 + _yOffset);
                            }
                            
                            _j += 2;
                        }
                        
                        ++_i;
                    }
                }
            }
            
            ++_x;
        }
        
        ++_y;
    }
}