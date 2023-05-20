/// @param tileset

function __BulbGetTileset(_tilesetIndex)
{
    static _tilesetDict = __BulbGlobal().__tilesetDict;
    var _tileset = _tilesetDict[$ _tilesetIndex];
    
    if (!is_struct(_tileset)) _tileset = new __BulbClassTileset(_tilesetIndex);
    return _tileset;
}