/// @param spriteIndex
/// @param imageIndex
/// @param [alphaThreshold=0]

#macro __BulbSpriteTraceEdge_Write  _lastWriteX = _x;\
                                    _lastWriteY = _y;\
                                    array_push(_loop, _x + _coordXOffset, _y + _coordYOffset);
                                    
#macro __BulbSpriteTraceEdge_WriteIfNecessary if ((_lastWriteX != _x) || (_lastWriteY != _y))\
                                              {\
                                                  __BulbSpriteTraceEdge_Write\
                                              }


function BulbSpriteTraceEdge(_sprite_index, _image_index, _alphaThreshold = 1/255)
{
    var _output = [];
    
    if ((_alphaThreshold <= 0) || (_alphaThreshold > 1))
    {
        __BulbError("Alpha threshold must be greater than 0.0 and less than or equal to 1.0");
        return;
    }
    
    _alphaThreshold *= 255;
    
    var _spriteWidth  = sprite_get_width( _sprite_index);
    var _spriteHeight = sprite_get_height(_sprite_index);
    var _originX      = sprite_get_xoffset(_sprite_index);
    var _originY      = sprite_get_yoffset(_sprite_index);
    
    var _coordXOffset = -1 - _originX;
    var _coordYOffset = -1 - _originY;
    
    var _surfaceWidth  = _spriteWidth  + 2;
    var _surfaceHeight = _spriteHeight + 2;
    var _surface = surface_create(_surfaceWidth, _surfaceHeight);
    
    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0.0);
    draw_sprite(_sprite_index, _image_index, 1 - _originX, 1 - _originY);
    surface_reset_target();
    
    var _bufferSize = 4*_surfaceWidth*_surfaceHeight;
    var _rowSize    = 4*_surfaceWidth;
    
    var _buffer = buffer_create(_bufferSize, buffer_fixed, 1);
    buffer_get_surface(_buffer, _surface, 0);
    buffer_seek(_buffer, buffer_seek_start, 0);
    surface_free(_surface);
    
    var _visitedGrid = ds_grid_create(_surfaceWidth, _surfaceHeight);
    // 0x00 = Unvisited
    // 0x01 = Visited right edge
    // 0x02 = Visited top edge
    // 0x04 = Visited left edge
    // 0x08 = Visited bottom edge
    
    while(true)
    {
        //Find first point of contact
        var _foundX = undefined;
        var _foundY = undefined;
        var _inside = false;
        
        var _y = 1;
        repeat(_spriteHeight)
        {
            var _x = 1;
            var _bufferPos = _y*_rowSize + 4*_x + 3;
            repeat(_spriteWidth)
            {
                //First byte in every 32-bit value is alpha (due to GM's native AGR layout)
                if (buffer_peek(_buffer, _bufferPos, buffer_u8) >= _alphaThreshold) //Alpha is greater than the threshold
                {
                    if (!_inside)
                    {
                        if ((_visitedGrid[# _x, _y] & 0x04) > 0)
                        {
                            //If we've already visited the left-hand side of this pixel, set us as inside
                            //We'll skip all interior pixels until we hit some empty space
                            _inside = true;
                        }
                        else
                        {
                            _foundX = _x;
                            _foundY = _y;
                            break;
                        }
                    }
                }
                else
                {
                    //We're outside!
                    _inside = false;
                }
                
                ++_x;
                _bufferPos += 4;
            }
        
            if (_foundX != undefined) break;
            ++_y;
        }
        
        if ((_foundX == undefined) && (_foundY == undefined))
        {
            //No more pixels to traverse
            break;
        }
        
        _x = _foundX;
        _y = _foundY;
        
        //Start a new loop
        var _loop = [];
        array_push(_output, _loop);
        
        __BulbSpriteTraceEdge_Write
        
        //We traverse the edge of the sprite clockwise
        // 0x01 = Heading right, checking edge is above us
        // 0x02 = Heading up, checking edge is to the left of us
        // 0x04 = Heading left, checking edge is below us
        // 0x08 = Heading down, checking edge is to the right of us
        //Since we just discovered
        var _direction = 0x02;
        
        var _open = true;
        while(_open)
        {
            var _bufferPos = _y*_rowSize + 4*_x + 3;
            switch(_direction)
            {
                case 0x01: //Right
                    //If we've already hit this edge then we've closed a loop and can stop
                    if ((_visitedGrid[# _x, _y] & 0x02) > 0)
                    {
                        _open = false;
                        break;
                    }
                    
                    _visitedGrid[# _x, _y] |= 0x02;
                    
                    if (buffer_peek(_buffer, _bufferPos - _rowSize + 4, buffer_u8) >= _alphaThreshold)
                    {
                        __BulbSpriteTraceEdge_WriteIfNecessary
                        
                        //There's a pixel to our top-right
                        ++_x;
                        --_y;
                        
                        __BulbSpriteTraceEdge_Write
                        
                        //We're an inside corner, rotate counterclockwise
                        _direction = 0x02;
                    }
                    else if (buffer_peek(_buffer, _bufferPos + 4, buffer_u8) >= _alphaThreshold)
                    {
                        //There's a pixel to the right of us
                        ++_x;
                    }
                    else
                    {
                        __BulbSpriteTraceEdge_WriteIfNecessary
                        
                        //We're an outside corner, rotate clockwise
                        _direction = 0x08;
                    }
                break;
                
                case 0x02: //Up
                    //If we've already hit this edge then we've closed a loop and can stop
                    if ((_visitedGrid[# _x, _y] & 0x04) > 0)
                    {
                        _open = false;
                        break;
                    }
                    
                    _visitedGrid[# _x, _y] |= 0x04;
                    
                    if (buffer_peek(_buffer, _bufferPos - _rowSize - 4, buffer_u8) >= _alphaThreshold)
                    {
                        __BulbSpriteTraceEdge_WriteIfNecessary
                        
                        //There's a pixel to our top-left
                        --_x;
                        --_y;
                        
                        __BulbSpriteTraceEdge_Write
                        
                        //We're an inside corner, rotate counterclockwise
                        _direction = 0x04;
                    }
                    else if (buffer_peek(_buffer, _bufferPos - _rowSize, buffer_u8) >= _alphaThreshold)
                    {
                        //There's a pixel above us
                        --_y;
                    }
                    else
                    {
                        __BulbSpriteTraceEdge_WriteIfNecessary
                        
                        //We're an outside corner, rotate clockwise
                        _direction = 0x01;
                    }
                break;
                
                case 0x04: //Left
                    //If we've already hit this edge then we've closed a loop and can stop
                    if ((_visitedGrid[# _x, _y] & 0x08) > 0)
                    {
                        _open = false;
                        break;
                    }
                    
                    _visitedGrid[# _x, _y] |= 0x08;
                    
                    if (buffer_peek(_buffer, _bufferPos + _rowSize - 4, buffer_u8) >= _alphaThreshold)
                    {
                        __BulbSpriteTraceEdge_WriteIfNecessary
                        
                        //There's a pixel to our bottom-left
                        --_x;
                        ++_y;
                        
                        __BulbSpriteTraceEdge_Write
                        
                        //We're an inside corner, rotate counterclockwise
                        _direction = 0x08;
                    }
                    else if (buffer_peek(_buffer, _bufferPos - 4, buffer_u8) >= _alphaThreshold)
                    {
                        //There's a pixel to the left of us
                        --_x;
                    }
                    else
                    {
                        __BulbSpriteTraceEdge_WriteIfNecessary
                        
                        //We're an outside corner, rotate clockwise
                        _direction = 0x02;
                    }
                break;
                
                case 0x08: //Down
                    //If we've already hit this edge then we've closed a loop and can stop
                    if ((_visitedGrid[# _x, _y] & 0x01) > 0)
                    {
                        _open = false;
                        break;
                    }
                    
                    _visitedGrid[# _x, _y] |= 0x01;
                    
                    if (buffer_peek(_buffer, _bufferPos + _rowSize + 4, buffer_u8) >= _alphaThreshold)
                    {
                        __BulbSpriteTraceEdge_WriteIfNecessary
                        
                        //There's a pixel to our bottom-right
                        ++_x;
                        ++_y;
                        
                        __BulbSpriteTraceEdge_Write
                        
                        //We're an inside corner, rotate counterclockwise
                        _direction = 0x01;
                    }
                    else if (buffer_peek(_buffer, _bufferPos + _rowSize, buffer_u8) >= _alphaThreshold)
                    {
                        //There's a pixel below us
                        ++_y;
                    }
                    else
                    {
                        __BulbSpriteTraceEdge_WriteIfNecessary
                        
                        //We're an outside corner, rotate clockwise
                        _direction = 0x04;
                    }
                break;
            }
        }
    }
    
    ds_grid_destroy(_visitedGrid);
    buffer_delete(_buffer);
    
    return _output;
}