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
    
    var _index = _tileX + _tileY*__BulbGetTilesetTilesWide(_tileset);
    var _tile = _tileDict[$ _index];
    
    if (!is_struct(_tile))
    {
        var _tile = new __BulbTile();
        _tileDict[$ _index] = _tile;
    }
    
    return _tile;
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