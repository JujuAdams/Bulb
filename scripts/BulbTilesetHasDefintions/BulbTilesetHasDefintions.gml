/// @param tileset

function BulbTilesetHasDefintions(_tileset)
{
    return variable_struct_exists(global.__bulbTilesetDict, _tileset);
}