function __BulbGetTilesetTilesHigh(_tileset)
{
    static _dict = {};
    
    var _tilesHigh = _dict[$ _tileset];
    if (_tilesHigh == undefined)
    {
        var _tilesetTexture = tileset_get_texture(_tileset);
        var _tilesetUVs     = tileset_get_uvs(_tileset);
        var _textureHeight  = (_tilesetUVs[3] - _tilesetUVs[1]) / texture_get_texel_height(_tilesetTexture);
        
        _tilesHigh = _textureHeight / (__BulbGetTilesetTileHeight(_tileset)+4);
        _dict[$ _tileset] = _tilesHigh;
    }
    
    return _tilesHigh;
}