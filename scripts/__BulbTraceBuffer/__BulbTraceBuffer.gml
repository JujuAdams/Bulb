/// @param buffer
/// @param bufferWidth
/// @param bufferHeight
/// @param bufferBorder
/// @param xOffset
/// @param yOffset
/// @param forceSinglePass
/// @param buildEdgesInHoles

function __BulbTraceBuffer(_buffer, _bufferWidth, _bufferHeight, _bufferBorder, _xOffset, _yOffset, _forceSinglePass, _buildEdgesInHoles)
{
    var _alphaThreshold = clamp(255*BULB_TRACE_ALPHA_THRESHOLD, 1, 255);
    
    var _output = [];
    
    var _spriteWidth  = _bufferWidth  - _bufferBorder;
    var _spriteHeight = _bufferHeight - _bufferBorder;
    var _rowSize      = 4*_bufferWidth;
    
    var _visitedGrid = ds_grid_create(_bufferWidth, _bufferHeight);
    // 0x00 = Unvisited
    // 0x01 = Visited right edge
    // 0x02 = Visited top edge
    // 0x04 = Visited left edge
    // 0x08 = Visited bottom edge
    
    var _searchX = 1;
    var _searchY = 1;
    var _inside  = false;
    
    while(true)
    {
        //Find the next point of contact
        var _found = false;
        
        while(_searchY < _spriteHeight)
        {
            while(_searchX < _spriteWidth)
            {
                //Last byte in every 32-bit value is alpha (due to GM's native ABGR layout)
                if (buffer_peek(_buffer, _searchY*_rowSize + 4*_searchX + 3, buffer_u8) >= _alphaThreshold) //Alpha is greater than the threshold
                {
                    if (!_inside)
                    {
                        _inside = true;
                        
                        if ((_visitedGrid[# _searchX, _searchY] & 0x04) > 0)
                        {
                            //If we've already visited the left-hand side of this pixel then we've already handled this pixel on a prior loop
                        }
                        else
                        {
                            _found = true;
                            break;
                        }
                    }
                }
                else if (_buildEdgesInHoles || ((_visitedGrid[# _searchX-1, _searchY] & 0x01) > 0))
                {
                    //We're outside!
                    _inside = false;
                }
                
                ++_searchX;
            }
        
            if (_found) break;
            
            _searchX = 1;
            ++_searchY;
        }
        
        if (!_found)
        {
            //No more pixels to traverse
            break;
        }
        
        var _pixelX = _searchX;
        var _pixelY = _searchY;
        
        //Start a new loop
        var _loop = [];
        array_push(_output, _loop);
        
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
            //Last byte in every 32-bit value is alpha (due to GM's native ABGR layout)
            var _bufferPos = _pixelY*_rowSize + 4*_pixelX + 3;
            switch(_direction)
            {
                case 0x01: //Right
                    //If we've already hit this edge then we've closed a loop and can stop
                    if ((_visitedGrid[# _pixelX, _pixelY] & 0x02) > 0)
                    {
                        _open = false;
                        break;
                    }
                    
                    _visitedGrid[# _pixelX, _pixelY] |= 0x02;
                    
                    if (buffer_peek(_buffer, _bufferPos - _rowSize + 4, buffer_u8) >= _alphaThreshold)
                    {
                        //There's a pixel to our top-right but no pixel directly to our right
                        array_push(_loop, _pixelX+1 + _xOffset, _pixelY + _yOffset);
                        
                        ++_pixelX;
                        --_pixelY;
                        
                        //We're an inside corner, rotate counterclockwise
                        _direction = 0x02;
                    }
                    else if (buffer_peek(_buffer, _bufferPos + 4, buffer_u8) >= _alphaThreshold)
                    {
                        //There's a pixel to the right of us
                        ++_pixelX;
                    }
                    else
                    {
                        array_push(_loop, _pixelX+1 + _xOffset, _pixelY + _yOffset);
                        
                        //We're an outside corner, rotate clockwise
                        _direction = 0x08;
                    }
                break;
                
                
                
                case 0x02: //Up
                    //If we've already hit this edge then we've closed a loop and can stop
                    if ((_visitedGrid[# _pixelX, _pixelY] & 0x04) > 0)
                    {
                        _open = false;
                        break;
                    }
                    
                    _visitedGrid[# _pixelX, _pixelY] |= 0x04;
                    
                    if (buffer_peek(_buffer, _bufferPos - _rowSize - 4, buffer_u8) >= _alphaThreshold)
                    {
                        //There's a pixel to our top-left
                        array_push(_loop, _pixelX + _xOffset, _pixelY + _yOffset);
                        
                        --_pixelX;
                        --_pixelY;
                        
                        //We're an inside corner, rotate counterclockwise
                        _direction = 0x04;
                    }
                    else if (buffer_peek(_buffer, _bufferPos - _rowSize, buffer_u8) >= _alphaThreshold)
                    {
                        //There's a pixel above us
                        --_pixelY;
                    }
                    else
                    {
                        array_push(_loop, _pixelX + _xOffset, _pixelY + _yOffset);
                        
                        //We're an outside corner, rotate clockwise
                        _direction = 0x01;
                    }
                break;
                
                
                
                case 0x04: //Left
                    //If we've already hit this edge then we've closed a loop and can stop
                    if ((_visitedGrid[# _pixelX, _pixelY] & 0x08) > 0)
                    {
                        _open = false;
                        break;
                    }
                    
                    _visitedGrid[# _pixelX, _pixelY] |= 0x08;
                    
                    if (buffer_peek(_buffer, _bufferPos + _rowSize - 4, buffer_u8) >= _alphaThreshold)
                    {
                        //There's a pixel to our bottom-left
                        array_push(_loop, _pixelX + _xOffset, _pixelY+1 + _yOffset);
                        
                        --_pixelX;
                        ++_pixelY;
                        
                        //We're an inside corner, rotate counterclockwise
                        _direction = 0x08;
                    }
                    else if (buffer_peek(_buffer, _bufferPos - 4, buffer_u8) >= _alphaThreshold)
                    {
                        //There's a pixel to the left of us
                        --_pixelX;
                    }
                    else
                    {
                        array_push(_loop, _pixelX + _xOffset, _pixelY+1 + _yOffset);
                        
                        //We're an outside corner, rotate clockwise
                        _direction = 0x02;
                    }
                break;
                
                
                
                case 0x08: //Down
                    //If we've already hit this edge then we've closed a loop and can stop
                    if ((_visitedGrid[# _pixelX, _pixelY] & 0x01) > 0)
                    {
                        _open = false;
                        break;
                    }
                    
                    _visitedGrid[# _pixelX, _pixelY] |= 0x01;
                    
                    if (buffer_peek(_buffer, _bufferPos + _rowSize + 4, buffer_u8) >= _alphaThreshold)
                    {
                        //There's a pixel to our bottom-right
                        array_push(_loop, _pixelX+1 + _xOffset, _pixelY+1 + _yOffset);
                        
                        ++_pixelX;
                        ++_pixelY;
                        
                        //We're an inside corner, rotate counterclockwise
                        _direction = 0x01;
                    }
                    else if (buffer_peek(_buffer, _bufferPos + _rowSize, buffer_u8) >= _alphaThreshold)
                    {
                        //There's a pixel below us
                        ++_pixelY;
                    }
                    else
                    {
                        array_push(_loop, _pixelX+1 + _xOffset, _pixelY+1 + _yOffset);
                        
                        //We're an outside corner, rotate clockwise
                        _direction = 0x04;
                    }
                break;
            }
        }
        
        //Close the loop
        array_push(_loop, _loop[0], _loop[1]);
        
        if (_forceSinglePass) break;
    }
    
    ds_grid_destroy(_visitedGrid);
    
    return _output;
}