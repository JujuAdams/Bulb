/// @param spriteIndex
/// @param imageIndex
/// @param [forceSinglePass=false]
/// @param [alphaThreshold=0]
/// @param [buildEdgesInHoles=false]

function BulbSpriteEdgeTrace(_spriteIndex, _imageIndex, _forceSinglePass = false, _alphaThreshold = 1/255, _buildEdgesInHoles = true)
{
    return (__BulbGetSpriteImage(_spriteIndex, _imageIndex)).__GetTrace();
    
    /*
    __BulbSpriteEnsureTag(_spriteIndex);
    
    var _spriteWidth  = sprite_get_width( _spriteIndex);
    var _spriteHeight = sprite_get_height(_spriteIndex);
    var _originX      = sprite_get_xoffset(_spriteIndex);
    var _originY      = sprite_get_yoffset(_spriteIndex);
    
    var _surfaceWidth  = _spriteWidth  + 2;
    var _surfaceHeight = _spriteHeight + 2;
    var _surface = surface_create(_surfaceWidth, _surfaceHeight);
    
    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0.0);
    draw_sprite(_spriteIndex, _image_index, 1 - _originX, 1 - _originY);
    surface_reset_target();
    
    var _buffer = buffer_create(4*_surfaceWidth*_surfaceHeight, buffer_fixed, 1);
    buffer_get_surface(_buffer, _surface, 0);
    buffer_seek(_buffer, buffer_seek_start, 0);
    surface_free(_surface);
    
    var _output = __BulbTraceBuffer(_buffer, _surfaceWidth, _surfaceHeight, 2, -1 - _originX, -1 - _originY, _forceSinglePass, _alphaThreshold, _buildEdgesInHoles);
    
    buffer_delete(_buffer);
    
    return _output;
    */
}