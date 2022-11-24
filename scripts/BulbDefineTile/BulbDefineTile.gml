/// @param tileset
/// @param tileX
/// @param tileY

function BulbDefineTile(_tileset, _tileX, _tileY)
{
    __BulbInitialize();
    
    var _tileDict = global.__bulbTilesetDict[$ _tileset];
    if (!is_struct(_tileDict))
    {
        _tileDict = {};
        global.__bulbTilesetDict[$ _tileset] = _tileDict;
    }
    
    var _index = string(_tileX + _tileY*__BulbGetTilesetTilesWide(_tileset));
    if (variable_struct_exists(_tileDict, _index))
    {
        __BulbError("A tile definition already exists for tilemap ", _tileset, ", tile ", _tileX, ",", _tileY, " (index=", _index, ")");
        return;
    }
    
    var _tile = new __BulbTile();
    _tileDict[$ _index] = _tile;
    return _tile;
}

function __BulbGetTilesetTilesWide(_tileset)
{
    static _dict = {};
    
    var _tilesWide = _dict[$ _tileset];
    if (_tilesWide == undefined)
    {
        layer_set_target_room(0);
        var _layer     = layer_create(0);
        var _tilemap   = layer_tilemap_create(_layer, 0, 0, _tileset, 1, 1);
        var _tileWidth = tilemap_get_tile_width(_tilemap);
        layer_tilemap_destroy(_tilemap);
        layer_destroy(_layer);
        layer_reset_target_room();
        
        var _tilesetTexture = tileset_get_texture(_tileset);
        var _tilesetUVs     = tileset_get_uvs(_tileset);
        var _textureWidth   = (_tilesetUVs[2] - _tilesetUVs[0]) / texture_get_texel_width(_tilesetTexture);
        
        _tilesWide = _textureWidth / (_tileWidth+4);
        _dict[$ _tileset] = _tilesWide;
    }
    
    return _tilesWide;
}

function __BulbTile() constructor
{
    __vertexArray = [];
    
    static AddEdge = function(_x1, _y1, _x2, _y2)
    {
        array_push(__vertexArray, _x1, _y1, _x2, _y2);
        return self;
    }
}