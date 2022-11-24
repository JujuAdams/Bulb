/// @param occluder
/// @param tilemap

function BulbAddTilemapToOccluder(_occluder, _tilemap)
{
    var _tileset = tilemap_get_tileset(_tilemap);
    var _tileDict = global.__bulbTilesetDict[$ _tileset];
    
    if (!is_struct(_tileDict))
    {
        __BulbError("Tileset ", _tileset, " has no tile definitions (tilemap ", _tilemap, ")");
        return;
    }
    
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
                var _tile = _tileDict[$ _tileIndex];
                if (is_struct(_tile)) _occluder.AddEdgesFromArray(_x*_tileWidth, _y*_tileHeight, _tile.__vertexArray);
            }
            
            ++_x;
        }
        
        ++_y;
    }
}