/// @param spriteIndex
/// @param imageIndex
/// @param [forceSinglePass=false]
/// @param [alphaThreshold=0]
/// @param [buildEdgesInHoles=false]

function BulbSpriteEdgeTrace(_spriteIndex, _imageIndex, _forceSinglePass = false, _alphaThreshold = 1/255, _buildEdgesInHoles = true)
{
    return (__BulbGetSpriteImage(_spriteIndex, _imageIndex)).__GetTrace();
}