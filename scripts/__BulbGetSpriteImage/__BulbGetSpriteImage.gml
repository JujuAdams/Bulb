/// @param spriteIndex
/// @param imageIndex

function __BulbGetSpriteImage(_spriteIndex, _imageIndex)
{
    static _global = __BulbGlobal();
    var _sprite = _global.__spriteDict[$ _spriteIndex];
    
    if (!is_struct(_sprite)) _sprite = new __BulbClassSprite(_spriteIndex);
    return _sprite.__imageArray[_imageIndex];
}