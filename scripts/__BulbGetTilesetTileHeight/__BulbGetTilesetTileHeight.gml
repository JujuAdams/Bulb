function __BulbGetTilesetTileHeight(_tileset)
{
    static _dict = {};
    
    var _tileHeight = _dict[$ _tileset];
    if (_tileHeight == undefined)
    {
        layer_set_target_room(0);
        var _layer      = layer_create(0);
        var _tilemap    = layer_tilemap_create(_layer, 0, 0, _tileset, 1, 1);
        var _tileHeight = tilemap_get_tile_height(_tilemap);
        layer_tilemap_destroy(_tilemap);
        layer_destroy(_layer);
        layer_reset_target_room();
        
        _dict[$ _tileset] = _tileHeight;
    }
    
    return _tileHeight;
}