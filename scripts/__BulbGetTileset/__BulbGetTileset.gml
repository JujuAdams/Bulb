/// @param tileset

function __BulbGetTileset(_tilesetIndex)
{
    var _tileset = global.__bulbTilesetDict[$ _tilesetIndex];
    if (!is_struct(_tileset)) _tileset = new __BulbClassTileset(_tilesetIndex);
    return _tileset;
}