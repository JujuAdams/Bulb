/// @param spriteIndex
/// @param imageIndex

function __BulbGetSpriteImage(_spriteIndex, _imageIndex)
{
    var _sprite = global.__bulbSpriteDict[$ _spriteIndex];
    if (!is_struct(_sprite)) _sprite = new __BulbClassSprite(_spriteIndex);
    return _sprite.__imageArray[_imageIndex];
}