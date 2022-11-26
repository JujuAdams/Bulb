function __BulbGetTilesetTileWidth(_tileset)
{
    static _dict = {};
    
    var _tileWidth = _dict[$ _tileset];
    if (_tileWidth == undefined)
    {
        layer_set_target_room(0);
        var _layer     = layer_create(0);
        var _tilemap   = layer_tilemap_create(_layer, 0, 0, _tileset, 1, 1);
        var _tileWidth = tilemap_get_tile_width(_tilemap);
        layer_tilemap_destroy(_tilemap);
        layer_destroy(_layer);
        layer_reset_target_room();
        
        _dict[$ _tileset] = _tileWidth;
    }
    
    return _tileWidth;
}