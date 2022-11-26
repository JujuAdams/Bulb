function __BulbGetTilesetTilesWide(_tileset)
{
    static _dict = {};
    
    var _tilesWide = _dict[$ _tileset];
    if (_tilesWide == undefined)
    {
        var _tilesetTexture = tileset_get_texture(_tileset);
        var _tilesetUVs     = tileset_get_uvs(_tileset);
        var _textureWidth   = (_tilesetUVs[2] - _tilesetUVs[0]) / texture_get_texel_width(_tilesetTexture);
        
        _tilesWide = _textureWidth / (__BulbGetTilesetTileWidth(_tileset)+4);
        _dict[$ _tileset] = _tilesWide;
    }
    
    return _tilesWide;
}